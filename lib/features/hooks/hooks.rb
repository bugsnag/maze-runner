# frozen_string_literal: true

require 'cucumber'
require 'json'
require 'securerandom'
require 'selenium-webdriver'

AfterConfiguration do |_cucumber_config|

  # Start mock server
  Maze::Server.start
  config = MazeRunner.config
  next if config.farm == :none

  # Setup Appium capabilities.  Note that the 'app' capability is
  # set in a hook as it will change if uploaded to BrowserStack.

  # BrowserStack specific setup
  if config.farm == :bs
    tunnel_id = SecureRandom.uuid
    if config.bs_device
      # BrowserStack device
      config.capabilities = Capabilities.for_browser_stack_device config.bs_device,
                                                                  tunnel_id,
                                                                  config.appium_version,
                                                                  config.capabilities_option

      config.app = BrowserStackUtils.upload_app config.username,
                                                config.access_key,
                                                config.app
      config.capabilities['app'] = config.app
    else
      # BrowserStack browser
      config.capabilities = Capabilities.for_browser_stack_browser config.bs_browser,
                                                                   tunnel_id,
                                                                   config.capabilities_option
    end
    BrowserStackUtils.start_local_tunnel config.bs_local,
                                         tunnel_id,
                                         config.access_key
  elsif config.farm == :local
    # Local device
    config.capabilities = Capabilities.for_local config.os,
                                                 config.capabilities_option,
                                                 config.apple_team_id,
                                                 config.device_id
    config.capabilities['app'] = config.app
  end

  # Create and start the relevant driver
  if config.bs_browser
    selenium_url = "http://#{config.username}:#{config.access_key}@hub.browserstack.com/wd/hub"
    MazeRunner.driver = SeleniumDriver.new selenium_url, config.capabilities
  else
    MazeRunner.driver = if MazeRunner.config.resilient
                          $logger.info 'Creating ResilientAppiumDriver instance'
                          ResilientAppiumDriver.new config.appium_server_url,
                                                    config.capabilities,
                                                    config.locator
                        else
                          $logger.info 'Creating AppiumDriver instance'
                          AppiumDriver.new config.appium_server_url,
                                           config.capabilities,
                                           config.locator
                        end
    MazeRunner.driver.start_driver unless config.appium_session_isolation
  end

  if config.farm == :bs && config.bs_device
    # Log a link to the BrowserStack session search dashboard
    build = MazeRunner.driver.caps[:build]
    url = "https://app-automate.browserstack.com/dashboard/v2/?searchQuery=#{build}"
    if ENV['BUILDKITE']
      $logger.info LogUtil.linkify url, 'BrowserStack session(s)'
    else
      $logger.info "BrowserStack session(s): #{url}"
    end
  end

  # Call any blocks registered by the client
  MazeRunner.hooks.call_after_configuration config
end

# Before each scenario
Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"

  MazeRunner.driver.start_driver if MazeRunner.config.farm != :none && MazeRunner.config.appium_session_isolation

  # Launch the app on macOS
  MazeRunner.driver.get(MazeRunner.config.app) if MazeRunner.config.os == 'macos'

  # Call any blocks registered by the client
  MazeRunner.hooks.call_before scenario
end

# General processing to be run after each scenario
After do |scenario|

  # Call any blocks registered by the client
  MazeRunner.hooks.call_after scenario

  # Make sure we reset to HTTP 200 return status after each scenario
  Maze::Server.status_code = 200
  Maze::Server.reset_status_code = false

  # This is here to stop sessions from one test hitting another.
  # However this does mean that tests take longer.
  # In addition, reset the last captured exit code
  # TODO:SM We could try and fix this by generating unique endpoints
  # for each test.
  Docker.down_all_services
  Docker.last_exit_code = nil
  Docker.last_command_logs = nil

  # Make sure that any scripts are killed between test runs
  # so future tests are run from a clean slate.
  Runner.kill_running_scripts

  Proxy.instance.stop

  # Log unprocessed requests if the scenario fails
  # TODO Revamp and log sessions
  if scenario.failed?
    STDOUT.puts '^^^ +++'
    if Maze::Server.sessions.empty?
      $logger.info 'No valid sessions received'
    else
      $logger.info "#{Maze::Server.sessions.size} sessions were received:"
      Maze::Server.sessions.all.each.with_index(1) do |request, number|
        $logger.info "Session #{number}:"
        LogUtil.log_hash(Logger::Severity::INFO, request)
      end
    end

    if Maze::Server.errors.empty?
      $logger.info 'No valid errors received'
    else
      $logger.info "#{Maze::Server.errors.size} errors were received:"
      Maze::Server.errors.all.each.with_index(1) do |request, number|
        $logger.info "Request #{number}:"
        LogUtil.log_hash(Logger::Severity::INFO, request)
      end
    end
  end

  next if MazeRunner.config.farm == :none || !MazeRunner.config.bs_browser.nil?

  if MazeRunner.config.appium_session_isolation
    MazeRunner.driver.driver_quit
  elsif MazeRunner.config.os == 'macos'
    # Close the app - without the sleep, launching the app for the next scenario intermittently fails
    system("killall #{MazeRunner.config.app} && sleep 1")
  else
    MazeRunner.driver.reset_with_timeout 2
  end
ensure
  # Request arrays in particular are cleared here, rather than in the Before hook, to allow requests to be registered
  # when a test fixture starts (which can be before the first Before scenario hook fires).
  Maze::Server.errors.clear
  Maze::Server.sessions.clear
  Maze::Server.invalid_requests.clear
  Runner.environment.clear
  Store.values.clear
end

# Check for invalid requests after each scenario.  This is its own hook as failing a scenario raises an exception
# and we need the logic in the other After hook to be performed.
# Furthermore, this hook should appear after the general hook as they are executed in reverse order by Cucumber.
After do |scenario|
  unless Maze::Server.invalid_requests.empty?
    Maze::Server.invalid_requests.each.with_index(1) do |request, number|
      $logger.error "Invalid request #{number} (#{request[:reason]}):"
      LogUtil.log_hash(Logger::Severity::ERROR, request)
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
  Docker.down_all_services

  next if MazeRunner.config.farm == :none

  # Stop the Appium session
  MazeRunner.driver.driver_quit unless MazeRunner.config.appium_session_isolation
end


