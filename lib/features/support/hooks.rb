# frozen_string_literal: true

require 'cucumber'
require 'fileutils'
require 'json'
require 'securerandom'
require 'selenium-webdriver'
require 'uri'

AfterConfiguration do |_cucumber_config|

  # Clear out maze_output folder
  maze_output = Dir.glob(File.join(Dir.pwd, 'maze_output', '*'))
  if Maze.config.file_log && !maze_output.empty?
    maze_output.each { |path| $logger.info "Clearing contents of #{path}" }
    FileUtils.rm_rf(maze_output)
  end

  # Record the local server starting time
  Maze.start_time = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  # Start mock server
  Maze::Server.start
  config = Maze.config

  next if config.farm == :none

  # Setup Appium capabilities.  Note that the 'app' capability is
  # set in a hook as it will change if uploaded to BrowserStack.

  # BrowserStack specific setup
  if config.farm == :bs
    tunnel_id = SecureRandom.uuid
    if config.device
      # BrowserStack device
      config.capabilities = Maze::Capabilities.for_browser_stack_device config.device,
                                                                        tunnel_id,
                                                                        config.appium_version,
                                                                        config.capabilities_option

      config.app = Maze::BrowserStackUtils.upload_app config.username,
                                                      config.access_key,
                                                      config.app
      config.capabilities['app'] = config.app
    else
      # BrowserStack browser
      config.capabilities = Maze::Capabilities.for_browser_stack_browser config.browser,
                                                                         tunnel_id,
                                                                         config.capabilities_option
    end
    Maze::BrowserStackUtils.start_local_tunnel config.bs_local,
                                               tunnel_id,
                                               config.access_key
  elsif config.farm == :sl
    tunnel_id = SecureRandom.uuid

    if config.device || config.os || config.os_version

      config.app = Maze::SauceLabsUtils.upload_app config.username,
                                                   config.access_key,
                                                   config.app
      # Capabilities
      Maze::SauceLabsUtils.start_sauce_connect config.sl_local,
                                               tunnel_id,
                                               config.username,
                                               config.access_key
      config.capabilities = Maze::Capabilities.for_sauce_labs_device config.device,
                                                                     config.os,
                                                                     config.os_version,
                                                                     tunnel_id,
                                                                     config.appium_version,
                                                                     config.capabilities_option

      config.capabilities['app'] = "storage:#{config.app}"
    else
      raise 'Browser support with Sauce Labs not yet implemented'

      # TODO: Sauce Labs browser
      # config.capabilities = Maze::Capabilities.for_browser_stack_browser config.browser,
      #                                                                    tunnel_id,
      #                                                                    config.capabilities_option
    end
  elsif config.farm == :bb
    config.app = Maze::BitBarUtils.upload_app config.access_key,
                                              config.app
    Maze::BitBarUtils.start_local_tunnel config.bb_local,
                                         config.username,
                                         config.access_key
    config.capabilities = Maze::Capabilities.for_bitbar_device config.access_key,
                                                               config.device,
                                                               config.capabilities_option

    config.capabilities['bitbar_app'] = config.app
    config.capabilities['bundleId'] = config.app_bundle_id
  elsif config.farm == :local
    # Local device
    config.capabilities = Maze::Capabilities.for_local config.os,
                                                       config.capabilities_option,
                                                       config.apple_team_id,
                                                       config.device_id
    config.capabilities['app'] = config.app

    # Attempt to start the local appium server
    appium_uri = URI(config.appium_server_url)
    Maze::AppiumServer.start(address: appium_uri.host, port: appium_uri.port) if config.start_appium
  end

  # Create and start the relevant driver
  if config.browser
    selenium_url = "http://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
    Maze.driver = Maze::Driver::Browser.new selenium_url, config.capabilities
  else
    Maze.driver = if Maze.config.resilient
                    $logger.info 'Creating ResilientAppium driver instance'
                    Maze::Driver::ResilientAppium.new config.appium_server_url,
                                                      config.capabilities,
                                                      config.locator
                  else
                    $logger.info 'Creating Appium driver instance'
                    Maze::Driver::Appium.new config.appium_server_url,
                                             config.capabilities,
                                             config.locator
                  end
    Maze.driver.start_driver unless config.appium_session_isolation
  end

  if config.farm == :bs && (config.device || config.browser)
    # Log a link to the BrowserStack session search dashboard
    build = Maze.driver.capabilities[:build]
    url = if config.device
            "https://app-automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
          else
            "https://automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
          end
    if ENV['BUILDKITE']
      $logger.info Maze::LogUtil.linkify url, 'BrowserStack session(s)'
    else
      $logger.info "BrowserStack session(s): #{url}"
    end
  end

  # Call any blocks registered by the client
  Maze.hooks.call_after_configuration config
end

# Before each scenario
Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"

  Maze.driver.start_driver if Maze.config.farm != :none && Maze.config.appium_session_isolation

  # Launch the app on macOS
  Maze.driver.get(Maze.config.app) if Maze.config.os == 'macos'

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

  if Maze.config.appium_session_isolation
    Maze.driver.driver_quit
  elsif Maze.config.os == 'macos'
    # Close the app - without the sleep, launching the app for the next scenario intermittently fails
    system("killall #{Maze.config.app} && sleep 1")
  elsif [:bs, :sl, :local].include? Maze.config.farm
    Maze.driver.reset
  elsif [:bb].include? Maze.config.farm
    Maze.driver.launch_app
  end
ensure
  # Request arrays in particular are cleared here, rather than in the Before hook, to allow requests to be registered
  # when a test fixture starts (which can be before the first Before scenario hook fires).
  Maze::Server.errors.clear
  Maze::Server.sessions.clear
  Maze::Server.builds.clear
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

  request_types = %w[errors sessions builds logs]

  request_types.each do |request_type|
    list = Maze::Server.list_for(request_type).all
    next if list.empty?

    filename = "#{request_type}.log"
    filepath = File.join(path, filename)

    counter = 1
    File.open(filepath, 'w+') do |file|
      file.puts "=== Request #{counter} of #{list.size} ==="
      list.each do |request|
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
at_exit do

  STDOUT.puts '+++ All scenarios complete'

  # Stop the mock server
  Maze::Server.stop

  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Maze::Docker.down_all_services

  # Specific shutdown when a device farm is configured
  next if Maze.config.farm == :none

  # Stop the Appium session and server
  Maze.driver.driver_quit unless Maze.config.appium_session_isolation
  Maze::AppiumServer.stop if Maze::AppiumServer.running

  if Maze.config.farm == :local && Maze.config.os == 'macos'
    # Acquire and output the logs for the current session
    Maze::Runner.run_command("log show --predicate '(process == \"#{Maze.config.app}\")' --style syslog --start '#{Maze.start_time}' > #{Maze.config.app}.log")
  elsif Maze.config.farm == :bs
    Maze::BrowserStackUtils.stop_local_tunnel
  elsif Maze.config.farm == :sl
    Maze::SauceLabsUtils.stop_sauce_connect
  elsif Maze.config.farm == :bb
    Maze::BitBarUtils.stop_local_tunnel
  end
end
