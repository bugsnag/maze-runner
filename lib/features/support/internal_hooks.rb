# frozen_string_literal: true

require 'cucumber'
require 'fileutils'
require 'json'
require 'securerandom'
require 'selenium-webdriver'
require 'uri'

BeforeAll do
  Maze.check = Maze::Checks::AssertCheck.new

  # Infer mode of operation from config, one of:
  # - Appium (using either remote or local devices)
  # - Browser (Selenium with local or remote browsers)
  # - Command (the software under test is invoked with a system call)
  # TODO Consider making this a specific command line option defaulting to Appium
  is_appium = [:bs, :bb, :local].include?(Maze.config.farm) && !Maze.config.app.nil?
  is_browser = !Maze.config.browser.nil?
  if is_appium
    Maze.mode = :appium
    Maze.internal_hooks = Maze::Hooks::AppiumHooks.new
  elsif is_browser
    Maze.mode = :browser
    Maze.internal_hooks = Maze::Hooks::BrowserHooks.new
  else
    Maze.mode = :command
    Maze.internal_hooks = Maze::Hooks::CommandHooks.new
  end
  $logger.info "Running in #{Maze.mode.to_s} mode"

  # Clear out maze_output folder and zip
  maze_output = Dir.glob(File.join(Dir.pwd, 'maze_output', '*'))
  if Maze.config.file_log && !maze_output.empty?
    maze_output.each { |path| $logger.info "Clearing contents of #{path}" }
    FileUtils.rm_rf(maze_output)
  end
  maze_output_zip = Dir.glob(File.join(Dir.pwd, 'maze_output.zip'))
  FileUtils.rm_rf(maze_output_zip)

  # Record the local server starting time
  Maze.start_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  # Give each run of the tool a unique id
  Maze.run_uuid = SecureRandom.uuid
  $logger.info "UUID for this run: #{Maze.run_uuid}"

  # Start mock server
  Maze::Server.start
  Maze::Server.set_response_delay_generator(Maze::Generator.new [Maze::Server::DEFAULT_RESPONSE_DELAY].cycle)
  Maze::Server.set_sampling_probability_generator(Maze::Generator.new [Maze::Server::DEFAULT_SAMPLING_PROBABILITY].cycle)
  Maze::Server.set_status_code_generator(Maze::Generator.new [Maze::Server::DEFAULT_STATUS_CODE].cycle)

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.before_all

  # Call any blocks registered by the client
  Maze.hooks.call_before_all

  # Determine public IP if enabled
  if Maze.config.aws_public_ip
    public_ip = Maze::AwsPublicIp.new
    Maze.public_address = public_ip.address
    $logger.info "Public address: #{Maze.public_address}"
  end

  # An initial setup for total success status
  $success = true
end

# @param config The Cucumber config
InstallPlugin do |config|
  # Start Bugsnag
  Maze::ErrorMonitor::Config.start_bugsnag(config)

  # Register exit code handler
  Maze::Hooks::ErrorCodeHook.register_exit_code_hook
  config.filters << Maze::Plugins::ErrorCodePlugin.new(config)

  # Only add the retry plugin if --retry is not used on the command line
  config.filters << Maze::Plugins::GlobalRetryPlugin.new(config) if config.options[:retry].zero?

  # Add step logging
  config.filters << Maze::Plugins::LoggingScenariosPlugin.new(config)
end

# Before each scenario
Before do |scenario|
  $logger.debug "Before hook - scenario.status: #{scenario.status}"
  next if scenario.status == :skipped

  Maze.scenario = Maze::Api::Cucumber::Scenario.new(scenario)

  # Skip scenario if the driver it needs has failed
  $logger.debug "Before hook - Maze.driver&.failed?: #{Maze.driver&.failed?}"
  if (Maze.mode == :appium || Maze.mode == :browser) && Maze.driver.failed?
    $logger.debug "Failing scenario because the #{Maze.mode.to_s} driver failed: #{Maze.driver.failure_reason}"
    scenario.fail('Cannot run scenario - driver failed')
  end

  # Default to no dynamic retry
  Maze.dynamic_retry = false

  if ENV['BUILDKITE']
    location = "\e[90m\t# #{scenario.location}\e[0m"
    $stdout.puts "--- Scenario: #{scenario.name} #{location}"
  end

  # Reset configuration values to their defaults
  Maze.config.unmanaged_traces_mode = false

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.before scenario

  # Call any blocks registered by the client
  Maze.hooks.call_before scenario

  # Invoke the logger hook for the scenario
  Maze::Hooks::LoggerHooks.before scenario

  Maze.config.span_timestamp_validation = true
end

# General processing to be run after each scenario
After do |scenario|
  $logger.debug "After hook 1 - scenario.status: #{scenario.status}"
  next if scenario.status == :skipped

  # If we're running on macos, take a screenshot if the scenario fails
  if Maze.config.os == "macos" && scenario.status == :failed
    Maze::MacosUtils.capture_screen(scenario)
  end

  # Invoke the logger hook for the scenario
  Maze::Hooks::LoggerHooks.after scenario

  # Call any blocks registered by the client
  Maze.hooks.call_after scenario

  # Stop terminating server if started by the Cucumber step
  Maze::TerminatingServer.stop

  # This is here to stop sessions from one test hitting another.
  # However this does mean that tests take longer.
  # In addition, reset the last captured exit code
  # TODO:SM We could try and fix this by generating unique endpoints
  # for each test.
  Maze::Docker.reset

  # Make sure that any scripts are killed between test runs
  # so future tests are run from a clean slate.
  Maze::Runner.kill_running_scripts

  Maze::Proxy.instance.stop

  # Log all received requests to the console if the scenario fails and/or config says to
  if (scenario.failed? && Maze.config.log_requests) || Maze.config.always_log
    $stdout.puts '^^^ +++' if ENV['BUILDKITE']
    output_received_requests('errors')
    output_received_requests('sessions')
    output_received_requests('traces')
    output_received_requests('builds')
    output_received_requests('logs')
    output_received_requests('ignored requests')
    output_received_requests('invalid requests')
  end

  # Keep a global record of the total test status for reporting purposes
  $success = !scenario.failed?

  # Log all received requests to file
  Maze::MazeOutput.new(scenario).write_requests if Maze.config.file_log

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.after scenario

ensure
  # Request arrays in particular are cleared here, rather than in the Before hook, to allow requests to be registered
  # when a test fixture starts (which can be before the first Before scenario hook fires).
  Maze::Server.reset!
  Maze::Runner.environment.clear
  Maze::Store.values.clear
  Maze::Aws::Sam.reset!
end

def output_received_requests(request_type)
  request_queue = Maze::Server.list_for(request_type)
  count = request_queue.size_all
  if count == 0
    $logger.info "No #{request_type} received"
  else
    $logger.info "#{count} #{request_type} were received:"
    request_queue.all.each.with_index(1) do |request, number|
      $stdout.puts "--- #{request_type} #{number} of #{count}"

      $logger.info 'Request:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:body])
      log_headers(request[:request])

      $logger.info 'Request digests:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:digests])

      unless request[:response].nil?
        $logger.info "Response: #{request[:response].body}"
        log_headers(request[:response])
      end
    end
  end
end

def log_headers(container)
  header = if container.respond_to?(:header)
             container.header
           elsif container.key?('header') || container.key?(:header)
             container['header'] || container[:header]
           else
             nil
           end
  unless header.nil?
    $logger.info 'Headers:'
    Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, header)
  end
end

# Check for invalid requests after each scenario.  This is its own hook as failing a scenario (which
# Maze.scenario.complete may invoke) raises an exception and we need the logic in the other After hook to be performed.
#
# Furthermore, this hook should appear after the general hook as they are executed in reverse order by Cucumber.
After do |scenario|
  $logger.debug "After hook 2 - scenario.status: #{scenario.status}"
  next if scenario.status == :skipped

  # Call any pre_complete hooks registered by the client
  Maze.hooks.call_pre_complete scenario

  # Fail the scenario if there are any invalid requests
  unless Maze::Server.invalid_requests.size_all == 0
    msg = "#{Maze::Server.invalid_requests.size_all} invalid request(s) received during scenario"
    Maze.scenario.mark_as_failed msg
  end

  # Fail the scenario if the driver failed, if the scenario hasn't already failed
  $logger.debug "After hook 2 - Maze.driver&.failed?: #{Maze.driver&.failed?}"
  if (Maze.mode == :appium || Maze.mode == :browser) && Maze.driver.failed? && !scenario.failed?
    $logger.debug "Marking scenario as failed because driver failed: #{Maze.driver.failure_reason}"
    Maze.scenario.mark_as_failed Maze.driver.failure_reason
  end

  Maze.scenario.complete
end

# Test all requests against schemas or extra validation rules.  These will only run if the schema/validation is
# specified for the specific endpoint
After do |scenario|
  $logger.debug "After hook 3 - scenario.status: #{scenario.status}"
  next if scenario.status == :skipped

  ['error', 'session', 'build', 'trace'].each do |endpoint|
    Maze::Schemas::Validator.validate_payload_elements(Maze::Server.list_for(endpoint), endpoint)
  end
end

# After all tests
AfterAll do
  # Ensure the logger output is in the correct location
  Maze::Hooks::LoggerHooks.after_all

  if Maze.config.file_log
    # create a zip file from the maze_output directory
    maze_output = File.join(Dir.pwd, 'maze_output')
    maze_output_zip = File.join(Dir.pwd, 'maze_output.zip')

    # zip a folder with files and subfolders
    Zip::File.open(maze_output_zip, Zip::File::CREATE) do |zipfile|
      Dir["#{maze_output}/**/**"].each do |file|
        zipfile.add(file.sub(Dir.pwd + '/', ''), file)
      end
    end

    # Move the zip file to the maze_output folder
    FileUtils.mv(maze_output_zip, maze_output)
  end

  metrics = Maze::MetricsProcessor.new(Maze::Server.metrics)
  metrics.process

  if Maze.timers.size.positive?
    $stdout.puts '--- Timer summary'
    Maze.timers.report
  end

  $stdout.puts '+++ All scenarios complete'

  # Stop the mock server
  Maze::Server.stop

  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Maze::Docker.down_all_services

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.after_all
end

at_exit do
  Maze.internal_hooks.at_exit
end
