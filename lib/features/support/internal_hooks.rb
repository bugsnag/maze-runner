# frozen_string_literal: true

require 'cucumber'
require 'fileutils'
require 'json'
require 'securerandom'
require 'selenium-webdriver'
require 'uri'

BeforeAll do

  # Infer mode of operation from config, one of:
  # - Appium (using either remote or local devices)
  # - Browser (Selenium with local or remote browsers)
  # - Command (the software under test is invoked with a system call)
  # TODO Consider making this a specific command line option defaulting to Appium
  is_appium = [:bs, :sl, :bb, :local].include?(Maze.config.farm) && !Maze.config.app.nil?
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

  # Clear out maze_output folder
  maze_output = Dir.glob(File.join(Dir.pwd, 'maze_output', '*'))
  if Maze.config.file_log && !maze_output.empty?
    maze_output.each { |path| $logger.info "Clearing contents of #{path}" }
    FileUtils.rm_rf(maze_output)
  end

  # Record the local server starting time
  Maze.start_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  # Start document server, if asked for
  Maze::DocumentServer.start unless Maze.config.document_server_root.nil?

  # Start mock server
  Maze::Server.start

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.after_configuration

  # Call any blocks registered by the client
  Maze.hooks.call_before_all
end

# Before each scenario
Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.before

  # Call any blocks registered by the client
  Maze.hooks.call_before scenario
end

# General processing to be run after each scenario
After do |scenario|

  # Call any blocks registered by the client
  Maze.hooks.call_after scenario

  # Make sure we reset to HTTP 200 return status after each scenario
  Maze::Server.status_code = 200
  Maze::Server.reset_status_code = false

  # Similarly for the response delay
  Maze::Server.response_delay_ms = 0
  Maze::Server.reset_response_delay = false

  # Stop document server if started by the Cucumber step
  Maze::DocumentServer.manual_stop

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

  # Log unprocessed requests on Buildkite if the scenario fails
  if (scenario.failed? && Maze.config.log_requests) || Maze.config.always_log
    STDOUT.puts '^^^ +++'
    output_received_requests('errors')
    output_received_requests('sessions')
    output_received_requests('builds')
    output_received_requests('logs')
  end

  # Log all received requests to file
  write_requests(scenario) if Maze.config.file_log

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.after

ensure
  # Request arrays in particular are cleared here, rather than in the Before hook, to allow requests to be registered
  # when a test fixture starts (which can be before the first Before scenario hook fires).
  Maze::Server.errors.clear
  Maze::Server.sessions.clear
  Maze::Server.builds.clear
  Maze::Server.uploads.clear
  Maze::Server.sourcemaps.clear
  Maze::Server.logs.clear
  Maze::Server.invalid_requests.clear
  Maze::Runner.environment.clear
  Maze::Store.values.clear
  Maze::Aws::Sam.reset!
end

def output_received_requests(request_type)
  request_queue = Maze::Server.list_for(request_type)
  if request_queue.empty?
    $logger.info "No valid #{request_type} received"
  else
    count = request_queue.size_all
    $logger.info "#{count} #{request_type} were received:"
    request_queue.all.each.with_index(1) do |request, number|
      STDOUT.puts "--- #{request_type} #{number} of #{count}"
      Maze::LogUtil.log_hash(Logger::Severity::INFO, request)
    end
  end
end

# Writes each list of requests to a separate file under, e.g:
# maze_output/failed/scenario_name/errors.log
def write_requests(scenario)
  folder1 = File.join(Dir.pwd, 'maze_output')
  folder2 = scenario.failed? ? 'failed' : 'passed'
  folder3 = scenario.name.gsub(/[:"& ]/, "_").gsub(/_+/, "_")

  path = File.join(folder1, folder2, folder3)

  FileUtils.makedirs(path)

  request_types = %w[errors sessions builds uploads logs sourcemaps]

  request_types.each do |request_type|
    list = Maze::Server.list_for(request_type).all
    next if list.empty?

    filename = "#{request_type}.log"
    filepath = File.join(path, filename)

    counter = 1
    File.open(filepath, 'w+') do |file|
      list.each do |request|
        file.puts "=== Request #{counter} of #{list.size} ==="
        file.puts "URI: #{request[:request].request_uri}"
        file.puts "HEADERS:"
        request[:request].header.each do |key, values|
          file.puts "  #{key}: #{values.map {|v| "'#{v}'"}.join(' ')}"
        end
        file.puts
        file.puts "BODY:"
        if request[:request].header["content-type"].first == 'application/json'
          file.puts JSON.pretty_generate(request[:body])
        else
          file.puts request[:body]
        end
        file.puts
        counter += 1
      end
    end
  end
end

# Check for invalid requests after each scenario.  This is its own hook as failing a scenario raises an exception
# and we need the logic in the other After hook to be performed.
# Furthermore, this hook should appear after the general hook as they are executed in reverse order by Cucumber.
After do |scenario|
  unless Maze::Server.invalid_requests.empty?
    Maze::Server.invalid_requests.each.with_index(1) do |request, number|
      $logger.error "Invalid request #{number} (#{request[:reason]}):"
      Maze::LogUtil.log_hash(Logger::Severity::ERROR, request)
    end
    msg = "#{Maze::Server.invalid_requests.length} invalid request(s) received during scenario"
    scenario.fail msg
  end
end

# After all tests
AfterAll do

  STDOUT.puts '+++ All scenarios complete'

  # Stop the mock server
  Maze::Server.stop

  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Maze::Docker.down_all_services

  # Invoke the internal hook for the mode of operation
  Maze.internal_hooks.call_after_all
end