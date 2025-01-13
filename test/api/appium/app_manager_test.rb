require 'appium_lib'

require_relative '../../test_helper'
require_relative '../../../lib/maze'
require_relative '../../../lib/maze/api/appium/app_manager'

module Maze
  module Api
    module Appium
      class AppManagerTest < Test::Unit::TestCase

        def setup()
          $logger = mock('logger')
          @mock_driver = mock('driver')
          Maze.driver = @mock_driver
          @manager = Maze::Api::Appium::AppManager.new
        end

        def test_state_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot get the app state - Appium driver failed.")

          assert_nil(@manager.state)
        end

        def test_close_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot close the app - Appium driver failed.")

          assert_false(@manager.close)
        end

        def test_launch_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot launch the app - Appium driver failed.")

          assert_false(@manager.launch)
        end

        def test_state_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:app_id).returns('app1')
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:app_state).with('app1').raises(Selenium::WebDriver::Error::ServerError, 'Timeout')

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.state
          end
          assert_equal 'Timeout', error.message
        end

        def test_close_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:close_app).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.close
          end
          assert_equal 'Timeout', error.message
        end

        def test_launch_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:launch_app).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.launch
          end
          assert_equal 'Timeout', error.message
        end
      end
    end
  end
end
