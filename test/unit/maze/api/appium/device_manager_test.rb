require 'appium_lib'

require_relative '../../../test_helper'
require_relative '../../../../../lib/maze'
require_relative '../../../../../lib/maze/api/appium/device_manager'

module Maze
  module Api
    module Appium
      class DeviceManagerTest < Test::Unit::TestCase

        def setup()
          $logger = mock('logger')
          @mock_driver = mock('driver')
          Maze.driver = @mock_driver
          @manager = Maze::Api::Appium::DeviceManager.new
        end

        def test_unlock_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot unlock the device - Appium driver failed.")

          assert_false(@manager.unlock)
        end

        def test_back_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot press the Back button - Appium driver failed.")

          assert_false(@manager.back)
        end

        def test_get_log_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot get logs - Appium driver failed.")

          assert_nil(@manager.get_log('syslog'))
        end

        def test_set_rotation_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot set the device rotation - Appium driver failed.")

          assert_false(@manager.set_rotation(:portrait))
        end

        def test_info_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot get the device info - Appium driver failed.")

          assert_nil(@manager.info)
        end

        def test_unlock_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:unlock).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Failed to unlock the device: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.unlock
          end
          assert_equal 'Timeout', error.message
        end

        def test_set_rotation_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:set_rotation).with(:landscape).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Failed to set the device rotation: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.set_rotation(:landscape)
          end
          assert_equal 'Timeout', error.message
        end

        def test_info_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:device_info).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Failed to get the device info: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.info
          end
          assert_equal 'Timeout', error.message
        end

        def test_back_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:back).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Failed to press back: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.back
          end
          assert_equal 'Timeout', error.message
        end

        def test_get_log_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:get_log).with('syslog').raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Failed to get logs: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.get_log('syslog')
          end
          assert_equal 'Timeout', error.message
        end
      end
    end
  end
end
