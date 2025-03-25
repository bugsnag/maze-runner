require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with the app.
      class UiManager < Maze::Api::Appium::Manager

        # Checks for an element, waiting until it is present or the method times out
        #
        # @param element_id [String] the element to search for
        # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
        # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
        #
        # @returns [Boolean] Whether the operation was successfully performed
        def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
          if failed_driver?
            $logger.error 'Cannot wait for element - Appium driver failed.'
            return false
          end

          @driver.wait_for_element(element_id, timeout, retry_if_stale)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Clicks a given element.
        #
        # @param element_id [String] the element to click
        #
        # @returns [Boolean] Whether the operation was successfully performed
        def click_element(element_id)
          if failed_driver?
            $logger.error 'Cannot click element - Appium driver failed.'
            return false
          end

          @driver.click_element(element_id)
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Clicks a given element if present.
        #
        # @param element_id [String] the element to click
        #
        # @returns [Boolean] Whether the element was clicked
        def click_element_if_present(element_id)
          if failed_driver?
            $logger.error 'Cannot click element - Appium driver failed.'
            return false
          end

          @driver.click_element_if_present(element_id)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end
      end
    end
  end
end
