require 'appium_lib'

require_relative '../../../test_helper'
require_relative '../../../../../lib/maze'
require_relative '../../../../../lib/maze/api/appium/ui_manager'

module Maze
  module Api
    module Appium
      class UiManagerTest < Test::Unit::TestCase

        def setup()
          $logger = mock('logger')
          @mock_driver = mock('driver')
          Maze.driver = @mock_driver
          @manager = Maze::Api::Appium::UiManager.new
        end

        def test_wait_for_element_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot wait for element - Appium driver failed.")

          assert_false(@manager.wait_for_element('element1'))
        end

        def test_click_element_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot click element - Appium driver failed.")

          assert_false(@manager.click_element('element1'))
        end

        def test_click_element_if_present_failed_driver
          @mock_driver.expects(:failed?).returns(true)
          $logger.expects(:error).with("Cannot click element - Appium driver failed.")

          assert_false(@manager.click_element_if_present('element1'))
        end

        def test_wait_for_element_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:wait_for_element).with('element1', 15, true).raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Error waiting for element element1: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.wait_for_element('element1')
          end
          assert_equal 'Timeout', error.message
        end

        def test_click_element_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:click_element).with('element1').raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Error clicking element element1: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.click_element('element1')
          end
          assert_equal 'Timeout', error.message
        end

        def test_click_element_if_present_server_error
          @mock_driver.expects(:failed?).returns(false)
          @mock_driver.expects(:fail_driver)
          @mock_driver.expects(:click_element_if_present).with('element1').raises(Selenium::WebDriver::Error::ServerError, 'Timeout')
          $logger.expects(:error).with("Error clicking element element1: Timeout")

          error = assert_raises Selenium::WebDriver::Error::ServerError do
            @manager.click_element_if_present('element1')
          end
          assert_equal 'Timeout', error.message
        end
      end
    end
  end
end
