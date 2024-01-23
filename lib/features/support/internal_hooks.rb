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

  # Start document server, if asked for
  # This must happen after any client hooks have run, so that they can set the server root
  Maze::DocumentServer.start unless Maze.config.document_server_root.nil?

  # Determine public IP if enabled
  if Maze.config.aws_public_ip
    public_ip = Maze::AwsPublicIp.new
    Maze.public_address = public_ip.address
    $logger.info "Public address: #{Maze.public_address}"

    unless Maze.config.document_server_root.nil?
      Maze.public_document_server_address = public_ip.document_server_address
      $logger.info "Public document server address: #{Maze.public_document_server_address}"
    end
  end

  # An initial setup for total success status
  $success = true
end

# @param config The Cucumber config
InstallPlugin do |config|
  # Start Bugsnag
  Maze::BugsnagConfig.start_bugsnag(config)

  if config.fail_fast?
    # Register exit code handler
    Maze::Hooks::ErrorCodeHook.register_exit_code_hook
    config.filters << Maze::Plugins::ErrorCodePlugin.new(config)
  end

  # Only add the retry plugin if --retry is not used on the command line
  config.filters << Maze::Plugins::GlobalRetryPlugin.new(config) if config.options[:retry].zero?

  # Add step logging
  config.filters << Maze::Plugins::LoggingScenariosPlugin.new(config)

  # TODO: Reporting of test failures as errors deactivated pending PLAT-10963
  #config.filters << Maze::Plugins::BugsnagReportingPlugin.new(config)
end

# Before each scenario
Before do |scenario|
  Maze.scenario = Maze::Api::Cucumber::Scenario.new(scenario)

  # Default to no dynamic try
  Maze.dynamic_retry = false

  if ENV['BUILDKITE']
    location = "\e[90m\t# #{scenario.location}\e[0m"
    $stdout.puts "--- Scenario: #{scenario.name} #{location}"
  end

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.before scenario

  # Call any blocks registered by the client
  Maze.hooks.call_before scenario

  # Invoke the logger hook for the scenario
  Maze::Hooks::LoggerHooks.before scenario
end

# General processing to be run after each scenario
After do |scenario|
  # If we're running on macos, take a screenshot if the scenario fails
  if Maze.config.os == "macos" && scenario.status == :failed
    Maze::MacosUtils.capture_screen(scenario)
  end

  # Invoke the logger hook for the scenario
  Maze::Hooks::LoggerHooks.after scenario

  # Call any blocks registered by the client
  Maze.hooks.call_after scenario

  # Stop document server if started by the Cucumber step
  Maze::DocumentServer.manual_stop

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

      $logger.info 'Request body:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:body])

      $logger.info 'Request headers:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:request].header)

      $logger.info 'Request digests:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:digests])

      $logger.info "Response body: #{request[:response].body}"
      $logger.info 'Response headers:'
      Maze::Loggers::LogUtil.log_hash(Logger::Severity::INFO, request[:response].header)
    end
  end
end

# Check for invalid requests after each scenario.  This is its own hook as failing a scenario (which
# Maze.scenario.complete may invoke) raises an exception and we need the logic in the other After hook to be performed.
#
# Furthermore, this hook should appear after the general hook as they are executed in reverse order by Cucumber.
After do |scenario|
  # Call any pre_complete hooks registered by the client
  Maze.hooks.call_pre_complete scenario

  unless Maze::Server.invalid_requests.size_all == 0
    msg = "#{Maze::Server.invalid_requests.size_all} invalid request(s) received during scenario"
    Maze.scenario.mark_as_failed msg
  end

  Maze.scenario.complete
end

# Test all requests against schemas or extra validation rules.  These will only run if the schema/validation is
# specified for the specific endpoint
After do |scenario|
  ['error', 'session', 'build', 'trace'].each do |endpoint|
    Maze::Schemas::Validator.verify_against_schema(Maze::Server.list_for(endpoint), endpoint)
    Maze::Schemas::Validator.validate_payload_elements(Maze::Server.list_for(endpoint), endpoint)
  end
end

# After all tests
AfterAll do
  # Ensure the logger output is in the correct location
  Maze::Hooks::LoggerHooks.after_all

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
