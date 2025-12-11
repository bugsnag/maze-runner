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
          $logger.error "Error waiting for element #{element_id}: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e)
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
          $logger.error "Error clicking element #{element_id}: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e)
          raise e
        end

        # Performs a touch operation at the given coordinates, using W3C actions.
        #
        # @param x [Integer] X coordinate
        # @param y [Integer] Y coordinate
        #
        # @returns [Boolean] Whether the operation was successfully performed
        def touch_at(x, y)
          if failed_driver?
            $logger.error 'Cannot perform touch - Appium driver failed.'
            return false
          end

          f1 = ::Selenium::WebDriver::Interactions.pointer(:touch, name: 'finger1')
          f1.create_pointer_move(duration: 1, x: x, y: y,
                                 origin: ::Selenium::WebDriver::Interactions::PointerMove::VIEWPORT)
          f1.create_pointer_down(:left)
          f1.create_pointer_up(:left)
          @driver.perform_actions([f1])
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          $logger.error "Error performing touch: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e)
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
          $logger.error "Error clicking element #{element_id}: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e)
          raise e
        end
      end
    end
  end
end
