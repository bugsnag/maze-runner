require 'json'
require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with the UI.
      class UiManager < Maze::Api::Appium::Manager

        # Checks for an element, waiting until it is present or the method times out
        #
        # @param element_id [String] the element to search for
        # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
        # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
        # @return [Boolean] Whether the element was found before the timeout
        def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
          if failed_driver?
            $logger.error 'Cannot wait for element - Appium driver failed.'
            return false
          end

          @driver.wait_for_element(element_id, timeout, retry_if_stale)
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver
          raise e
        end

        # Clicks and element if it is present
        #
        # @param element_id [String] the element to click
        def click_element_if_present(element_id)
          if failed_driver?
            $logger.error 'Cannot click element - Appium driver failed.'
            return false
          end

          @driver.click_element_if_present(element_id)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver
          raise e
        end
      end
    end
  end
end
