# frozen_string_literal: true

require 'cucumber'
require 'json'

AfterConfiguration do |config|
  Server.start_server
end

# Before each scenario
Before do |scenario|
  STDOUT.puts "--- Scenario: #{scenario.name}"
  Runner.environment.clear
  Server.stored_requests.clear
  Store.values.clear

  $driver.start_driver if MazeRunner.configuration.appium_session_isolation
end

# After each scenario
After do |scenario|

  $driver.driver_quit if MazeRunner.configuration.appium_session_isolation

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
end

# After all tests
at_exit do
  # Stop the mock server
  Server.stop_server

  # In order to not impact future test runs, we down
  # all services (which removes networks etc) so that
  # future test runs are from a clean slate.
  Docker.down_all_services
end

