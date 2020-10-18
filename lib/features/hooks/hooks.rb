# frozen_string_literal: true

require 'cucumber'
require 'json'
require 'securerandom'

AfterConfiguration do |config|

  # Start mock server
  Server.start_server
  config = MazeRunner.config
  next if config.farm == :none

  # Setup Appium capabilities.  Note that the 'app' capability is
  # set in a hook as it will change if uploaded to BrowserStack.

  # BrowserStack specific setup
  if config.farm == :bs
    tunnel_id = SecureRandom.uuid
    config.capabilities = Capabilities.for_browser_stack config.device_type,
                                                         tunnel_id

    config.app_location = BrowserStackUtils.upload_app config.username,
                                                       config.access_key,
                                                       config.app_location
    BrowserStackUtils.start_local_tunnel config.bs_local,
                                         tunnel_id,
                                         config.access_key
  elsif config.farm == :local
    config.capabilities = Capabilities.for_local config.device_type,
                                                 config.apple_team_id,
                                                 config.device_id
  end
  # Set app location (file or url) in capabilities
  config.capabilities['app'] = config.app_location

  # Create and start the drive
  MazeRunner.driver = ResilientAppiumDriver.new config.appium_server_url,
                                                config.capabilities
  MazeRunner.driver.start_driver unless config.appium_session_isolation

  # TODO: We need to get hold of OS version (or API level) of the actual device that is used.  We used to take this from
  #   the DEVICE_TYPE provided, but with local device use you can just ask for "iOS" and it will use whatever you have
  #   plugged in.
  #   One of these seems to only work on BrowserStack and the other only locally - further investigation needed.
  # puts "Actual driver capabilities #{MazeRunner.driver.capabilities}"
  # puts 'Device info:'
  # puts JSON.pretty_generate MazeRunner.driver.device_info
  # puts 'Session capabilities:'
  # puts JSON.pretty_generate MazeRunner.driver.session_capabilities
end

# Before each scenario
Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"
  Runner.environment.clear
  Server.stored_requests.clear
  Store.values.clear

  next if MazeRunner.config.farm == :none

  MazeRunner.driver.start_driver if MazeRunner.config.appium_session_isolation
end

# After each scenario
After do |scenario|

  # This is here to stop sessions from one test hitting another.
  # However this does mean that tests take longer.
  # TODO:SM We could try and fix this by generating unique endpoints
  # for each test.
  Docker.down_all_services

  # Make sure that any scripts are killed between test runs
  # so future tests are run from a clean slate.
  Runner.kill_running_scripts

  Proxy.instance.stop

  # Log unprocessed requests if the scenario fails
  if scenario.failed?
    STDOUT.puts '^^^ +++'
    if Server.stored_requests.empty?
      $logger.info 'No requests received'
    else
      $logger.info 'The following requests were received:'
      Server.stored_requests.each.with_index(1) do |request, number|
        $logger.info "Request #{number}:"
        LogUtil.log_hash(Logger::Severity::INFO, request)
      end
    end
  end

  next if MazeRunner.config.farm == :none

  if MazeRunner.config.appium_session_isolation
    MazeRunner.driver.driver_quit
  else
    MazeRunner.driver.reset_with_timeout 2
  end
end

# After all tests
at_exit do
  # Stop the mock server
  Server.stop_server

  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Docker.down_all_services

  next if MazeRunner.config.farm == :none

  # Stop the Appium session
  MazeRunner.driver.driver_quit unless MazeRunner.config.appium_session_isolation
end

