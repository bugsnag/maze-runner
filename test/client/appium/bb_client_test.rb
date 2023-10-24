require_relative '../../test_helper'
require_relative '../../../lib/maze'
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

        def setup
          logger_mock = mock('logger')
          $logger = logger_mock
        end

        def test_start_driver_success
          Maze.driver = nil

          # Setup inputs
          client = BitBarClient.new
          Maze.config.app = 'app'
          Maze.config.access_key = 'apiKey'
          Maze.config.appium_server_url = 'appium server'
          Maze.config.capabilities_option = '{"config":"capabilities"}'
          Maze.config.locator = :id

          # Dashboard caps
          dashboard_caps = {
            'bitbar:options' => {
              bitbar_project: 'project',
              bitbar_testrun: 'test_run'
            }
          }
          Maze::Client::BitBarClientUtils.expects(:dashboard_capabilities).returns dashboard_caps

          # Device caps
          device_caps = {
            'platformName' => 'iOS'
          }
          Maze::Client::Appium::BitBarDevices.expects(:get_available_device).returns device_caps

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
          mock_driver = mock('driver')
          Maze::Driver::Appium.expects(:new).with(Maze.config.appium_server_url,
                                                  expected_caps,
                                                  Maze.config.locator).returns mock_driver

          # Starting of the driver
          mock_driver.expects(:session_id).twice.returns 'session_id'
          mock_driver.expects(:session_capabilities).returns({ 'uuid' => 'uuid' })
          mock_driver.expects(:start_driver).returns true
          BitBarApiClient.stubs(:new)

          # Logging
          $logger.expects(:info).with('Created Appium session: session_id')


          client.start_driver Maze.config
        end
      end
    end
  end
end
