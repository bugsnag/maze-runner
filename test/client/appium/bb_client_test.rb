require 'bugsnag'
require_relative '../../test_helper'
require_relative '../../../lib/maze'
require_relative '../../../lib/maze/api/exit_code'
require_relative '../../../lib/maze/configuration'
require_relative '../../../lib/maze/driver/appium'
require_relative '../../../lib/maze/client/bb_api_client'
require_relative '../../../lib/maze/client/bb_client_utils'
require_relative '../../../lib/maze/client/appium/base_client'
require_relative '../../../lib/maze/client/appium/bb_client'
require_relative '../../../lib/maze/client/appium/bb_devices'
require_relative '../../../lib/utils/deep_merge'

module Maze
  module Client
    module Appium
      class BitBarClientTest < Test::Unit::TestCase

        def add_attempt_expectations(attempts = 1)
          # Dashboard caps
          dashboard_caps = {
            'bitbar:options' => {
              bitbar_project: 'project',
              bitbar_testrun: 'test_run'
            }
          }
          Maze::Client::BitBarClientUtils.expects(:dashboard_capabilities).times(attempts).returns dashboard_caps

          # Device caps
          device_caps = {
            'platformName' => 'iOS'
          }
          Maze::Client::Appium::BitBarDevices.expects(:get_available_device).times(attempts).returns device_caps

          # Driver creation
          expected_caps = {
            'appium:options' => {
              'noReset' => true,
              'newCommandTimeout' => 600
            },
            'bitbar:options' => {
              'apiKey' => 'apiKey',
              'app' => 'app',
              'findDevice' => false,
              'testTimeout' => 7200,
              :bitbar_project => 'project',
              :bitbar_testrun => 'test_run'},
            'platformName' => 'iOS',
            'config' => 'capabilities'
          }
          Maze::Driver::Appium.expects(:new).with(Maze.config.appium_server_url,
                                                  expected_caps,
                                                  Maze.config.locator).times(attempts).returns @mock_driver
        end

        def setup
          BitBarApiClient.stubs(:new)
          $logger = mock('logger')
          @mock_driver = mock('driver')

          # Setup inputs
          Maze.driver = nil
          Maze.config.app = 'app'
          Maze.config.access_key = 'apiKey'
          Maze.config.appium_server_url = 'appium server'
          Maze.config.capabilities_option = '{"config":"capabilities"}'
          Maze.config.locator = :id
          Maze.config.appium_version = nil
        end

        def test_start_driver_success

          add_attempt_expectations

          # Logging
          @mock_driver.expects(:start_driver).returns true
          $logger.expects(:info).with('Created Appium session: session_id')

          # Successful starting of the driver
          @mock_driver.expects(:session_id).twice.returns 'session_id'
          @mock_driver.expects(:session_capabilities).returns({ 'uuid' => 'uuid' })
          Bugsnag.expects(:notify).never

          client = BitBarClient.new
          client.start_driver Maze.config
        end

        def test_start_driver_recovers

          add_attempt_expectations 2

          #
          # First attempt - failure
          #
          message = 'no sessionId in returned payload'
          @mock_driver.expects(:start_driver).twice.raises(message).then.returns(true)
          $logger.expects(:error).with("Session creation failed: #{message}")
          interval = 60
          $logger.expects(:warn).with("Failed to create Appium driver, retrying in #{interval} seconds")
          Kernel.expects(:sleep).with(interval)

          #
          # Second attempt - success
          #
          $logger.expects(:info).with('Created Appium session: session_id')
          @mock_driver.expects(:session_id).twice.returns 'session_id'
          @mock_driver.expects(:session_capabilities).returns({ 'uuid' => 'uuid' })
          Bugsnag.expects(:notify).never

          client = BitBarClient.new
          client.start_driver Maze.config
        end

        def test_start_driver_failure
          add_attempt_expectations 2
          message_1 = 'You reached the account concurrency limit'
          message_2 = 'There are no devices available'

          #
          # First attempt - failure
          #
          @mock_driver.expects(:start_driver).twice.raises(message_1).then.raises(message_2)
          $logger.expects(:error).with("Session creation failed: #{message_1}")

          interval = 300
          $logger.expects(:warn).with("Failed to create Appium driver, retrying in #{interval} seconds")
          Kernel.expects(:sleep).with(interval)

          #
          # Second attempt - also fails
          #
          $logger.expects(:error).with("Session creation failed: #{message_2}")
          Kernel.expects(:exit).with(::Maze::Api::ExitCode::SESSION_CREATION_FAILURE)
          $logger.expects(:error).with("Failed to create Appium driver, exiting")
          Bugsnag.expects(:notify).twice

          client = BitBarClient.new
          client.start_driver Maze.config, 2
        end

        def test_device_caps_new_appium
          Maze.config.appium_version = '2.0'

          dashboard_caps = {
            'bitbar:options' => {
              'bitbar_project' => 'project',
              'bitbar_testrun' => 'test_run'
            }
          }
          Maze::Client::BitBarClientUtils.expects(:dashboard_capabilities).returns dashboard_caps

          device_caps = {
            'platformName' => 'iOS'
          }
          Maze::Client::Appium::BitBarDevices.expects(:get_available_device).returns device_caps

          client = BitBarClient.new
          device_caps = client.device_capabilities

          expected_caps = {
            'appium:options' => {
              'noReset' => true,
              'newCommandTimeout' => 600,
            },
            'bitbar:options' => {
              'apiKey' => 'apiKey',
              'app' => 'app',
              'findDevice' => false,
              'testTimeout' => 7200,
              'bitbar_project' => 'project',
              'bitbar_testrun' => 'test_run',
              'appiumVersion' => '2.0'
            },
            'platformName' => 'iOS',
            'config' => 'capabilities'
          }

          assert_equal expected_caps, device_caps
        end

        def test_device_caps_old_appium
          Maze.config.appium_version = '1.5'

          dashboard_caps = {
            'bitbar:options' => {
              'bitbar_project' => 'project',
              'bitbar_testrun' => 'test_run'
            }
          }
          Maze::Client::BitBarClientUtils.expects(:dashboard_capabilities).returns dashboard_caps

          device_caps = {
            'platformName' => 'iOS'
          }
          Maze::Client::Appium::BitBarDevices.expects(:get_available_device).returns device_caps

          client = BitBarClient.new
          device_caps = client.device_capabilities

          expected_caps = {
            'noReset' => true,
            'newCommandTimeout' => 600,
            'bitbar:options' => {
              'apiKey' => 'apiKey',
              'app' => 'app',
              'findDevice' => false,
              'testTimeout' => 7200,
              'bitbar_project' => 'project',
              'bitbar_testrun' => 'test_run',
              'appiumVersion' => '1.5'
            },
            'platformName' => 'iOS',
            'config' => 'capabilities'
          }

          assert_equal expected_caps, device_caps
        end
      end
    end
  end
end
