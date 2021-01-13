require 'appium_lib'
require 'json'
require 'open3'
require 'securerandom'
require_relative '../logger'
require_relative '../../maze'

module Maze
  module Driver
    # Provide a thin layer of abstraction above @see Appium::Driver
    class Appium < Appium::Driver

      # @!attribute [r] device_type
      #   @return [String] The device, from the list of device capabilities, used for this test
      attr_reader :device_type

      # @!attribute [r] capabilities
      #   @return [Hash] The capabilities used to launch the BrowserStack instance
      attr_reader :capabilities

      # Creates the Appium driver
      #
      # @param server_url [String] URL of the Appium server
      # @param capabilities [Hash] a hash of capabilities to be used in this test run
      # @param locator [Symbol] the primary locator strategy Appium should use to find elements
      def initialize(server_url, capabilities, locator = :id)
        # Sets up identifiers for ease of connecting jobs
        name_capabilities = project_name_capabilities

        @element_locator = locator
        @capabilities = capabilities
        @capabilities.merge! name_capabilities

        super({
          'caps' => @capabilities,
          'appium_lib' => {
            server_url: server_url
          }
        }, true)

        $logger.info 'Appium driver initialized for:'
        $logger.info "    project : #{name_capabilities[:project]}"
        $logger.info "    build   : #{name_capabilities[:build]}"
      end

      # Starts the Appium driver
      def start_driver
        $logger.info 'Starting Appium driver...'
        time = Time.now
        super
        $logger.info "Appium driver started in #{(Time.now - time).to_i}s"
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
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => stale_error
        if retry_if_stale
          wait_for_element(element_id, timeout, false)
        else
          $logger.warn "StaleElementReferenceError occurred: #{stale_error}"
          false
        end
      else
        true
      end

      # Clicks a given element
      #
      # @param element_id [String] the element to click
      def click_element(element_id)
        find_element(@element_locator, element_id).click
      end

      # Clears a given element
      #
      # @param element_id [String] the element to clear
      def clear_element(element_id)
        find_element(@element_locator, element_id).clear
      end

      # Sends keys to a given element
      #
      # @param element_id [String] the element to send text to
      # @param text [String] the text to send
      def send_keys_to_element(element_id, text)
        find_element(@element_locator, element_id).send_keys(text)
      end

      # Sends keys to a given element, clearing it first
      #
      # @param element_id [String] the element to clear and send text to
      # @param text [String] the text to send
      def clear_and_send_keys_to_element(element_id, text)
        element = find_element(@element_locator, element_id)
        element.clear
        element.send_keys(text)
      end

      # Reset the currently running application after a given timeout
      #
      # @param timeout [Number] the amount of time in seconds to wait before resetting
      def reset_with_timeout(timeout = 0.1)
        sleep(timeout)
        reset
      end

      # Determines and returns sensible project, build, and name capabilities
      #
      # @return [Hash] A hash containing the 'project' and 'build' capabilities
      def project_name_capabilities
        # Default to values for running locally
        project = 'local'
        build = SecureRandom.uuid

        if ENV['BUILDKITE']
          # Project
          project = ENV['BUILDKITE_PIPELINE_NAME']
        end
        {
          project: project,
          build: build
        }
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
