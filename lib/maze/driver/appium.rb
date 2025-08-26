require 'appium_lib'
require 'bugsnag'
require 'json'
require 'open3'
require 'securerandom'
require_relative '../loggers/logger'
require_relative '../../maze'

module Maze
  module Driver
    # Provide a thin layer of abstraction above @see Appium::Driver
    class Appium < Appium::Driver

      # @!attribute [rw] app_id
      #   @return [String] The app_id derived from session_capabilities (appPackage on Android, bundleID on iOS)
      attr_accessor :app_id

      # @!attribute [r] device_type
      #   @return [String] The device, from the list of device capabilities, used for this test
      attr_reader :device_type

      # @!attribute [r] capabilities
      #   @return [Hash] The capabilities used to launch the Appium session
      attr_reader :capabilities

      # Creates the Appium driver
      #
      # @param server_url [String] URL of the Appium server
      # @param capabilities [Hash] a hash of capabilities to be used in this test run
      # @param locator [Symbol] the primary locator strategy Appium should use to find elements
      def initialize(server_url, capabilities, locator = :id)
        # Sets up identifiers for ease of connecting jobs
        capabilities ||= {}

        @failed = false
        @failure_reason = ''
        @element_locator = locator
        @capabilities = capabilities

        # Timers
        @find_element_timer = Maze.timers.add 'Appium - find element'
        @click_element_timer = Maze.timers.add 'Appium - click element'

        super({
          'caps' => @capabilities,
          'appium_lib' => {
            server_url: server_url
          }
        }, true)
      end

      # Starts the Appium driver
      def start_driver
        begin
          $logger.info 'Starting Appium driver...'
          time = Time.now
          super
          $logger.info "Appium driver started in #{(Time.now - time).to_i}s"
        rescue => error
          $logger.warn "Appium driver failed to start in #{(Time.now - time).to_i}s"
          $logger.warn "#{error.class} occurred with message: #{error.message}"
          # Do not Bugsnag.notify here as we re-raise the error
          raise error
        end
      end

      # Whether the driver has known to have failed (it may still have failed and us not know yet)
      def failed?
        @failed
      end

      def failure_reason
        @failure_reason
      end

      # Marks the driver as failed
      def fail_driver(reason)
        $logger.error "Appium driver failed: #{reason}"
        @failed = true
        @failure_reason = reason
      end

      # Checks for an element, waiting until it is present or the method times out
      #
      # @param element_id [String] the element to search for
      # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
      # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
      def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
        wait = Selenium::WebDriver::Wait.new(timeout: timeout)
        wait.until { find_element(@element_locator, element_id).displayed? }
      rescue Selenium::WebDriver::Error::TimeoutError
        false
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        if retry_if_stale
          wait_for_element(element_id, timeout, false)
        else
          $logger.warn "StaleElementReferenceError occurred: #{e}"
          false
        end
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      else
        true
      end

      # A wrapper around launch_app adding extra error handling
      def launch_app
        super
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      end

      # A wrapper around close_app adding extra error handling
      def close_app
        super
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      end

      # A wrapper around find_element adding timer functionality
      def find_element_timed(element_id)
        @find_element_timer.time do
          find_element(@element_locator, element_id)
        end
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      end

      # Clicks a given element
      #
      # @param element_id [String] the element to click
      def click_element(element_id)
        element = find_element_timed(element_id)
        @click_element_timer.time do
          element.click
        end
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      end

      # Clicks a given element, ignoring any NoSuchElementError
      #
      # @param element_id [String] the element to click
      # @return [Boolean] True is the element was clicked
      def click_element_if_present(element_id)
        element = find_element_timed(element_id)
        @click_element_timer.time do
          element.click
        end
        true
      rescue Selenium::WebDriver::Error::NoSuchElementError
        false
      rescue Selenium::WebDriver::Error::ServerError => e
        # Assume the remote appium session has stopped, so crash out of the session
        fail_driver(e)
        raise e
      end

      # Gets the application hierarchy XML
      def page_source
        @driver.page_source
      end

      # Unlocks the device
      def unlock
        @driver.unlock
      end

      # Sets the rotation of the device
      #
      # @param orientation [Symbol] :portrait or :landscape
      def set_rotation(orientation)
        @driver.rotation = orientation
      end

      def window_size
        @driver.window_size
      end

      def device_info
        driver.execute_script('mobile:deviceInfo')
      end

      def session_capabilities
        driver.session_capabilities
      end
    end
  end
end
