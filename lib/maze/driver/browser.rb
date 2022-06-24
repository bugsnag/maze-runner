# frozen_string_literal: true

require 'selenium-webdriver'

module Maze
  module Driver
    # Handles browser automation fundamentals
    class Browser
      # @!attribute [r] capabilities
      #   @return [Hash] The capabilities used to launch the BrowserStack instance
      attr_reader :capabilities

      def initialize(driver_for, selenium_url=nil, capabilities=nil)
        capabilities.merge! project_name_capabilities
        @capabilities = capabilities
        @driver_for = driver_for
        @selenium_url = selenium_url

        start_driver
      end

      def find_element(*args)
        @driver.find_element(*args)
      end

      def navigate
        @driver.navigate
      end

      # Refreshes the page
      def refresh
        @driver.refresh
      end

      # Quits the driver
      def driver_quit
        @driver.quit
      end

      # check if Selenium supports running javascript in the current browser
      def javascript?
        @driver.execute_script('return true')
      rescue Selenium::WebDriver::Error::UnsupportedOperationError
        false
      end

      # check if the browser supports local storage, e.g. safari 10 on browserstack
      # does not have working local storage
      def local_storage?
        # Assume we can use local storage if we aren't able to verify by running JavaScript
        return true unless javascript?

        @driver.execute_script <<-JAVASCRIPT
      try {
        window.localStorage.setItem('__localstorage_test__', 1234)
        window.localStorage.removeItem('__localstorage_test__')

        return true
      } catch (err) {
        return false
      }
        JAVASCRIPT
      end

      # Determines and returns sensible project and build capabilities
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

      # Restarts the underlying-driver in the case an unrecoverable error occurs
      #
      # @param attempts [Integer] The number of times we should retry a failed attempt (defaults to 6)
      def restart_driver(attempts=6)
        # Remove the old driver
        @driver.quit
        @driver = nil

        start_driver(attempts)
      end

      private

      # Attempts to create a new selenium driver a given number of times
      #
      # @param attempts [Integer] The number of times we should retry a failed attempt (defaults to 6)
      def start_driver(attempts=6)
        timeout = attempts * 10
        wait = Maze::Wait.new(interval: 10, timeout: timeout)
        success = wait.until do
          begin
            create_driver(@driver_for, @selenium_url)
          rescue => error
            $logger.warn "#{error.class} occurred with message: #{error.message}"
          end
          @driver
        end

        unless success
          $logger.error "Selenium driver failed to start after #{attempts} attempts in #{timeout} seconds"
          raise RuntimeError.new("Appium driver failed to start in #{timeout} seconds")
        end
      end

      # Creates and starts the selenium driver
      def create_driver(driver_for, selenium_url=nil)
        begin
          $logger.info "Starting Selenium driver"
          time = Time.now
          if driver_for == :remote
            driver = ::Selenium::WebDriver.for :remote,
                                                url: selenium_url,
                                                desired_capabilities: @capabilities
          else
            driver = ::Selenium::WebDriver.for driver_for
          end
          $logger.info "Selenium driver started in #{(Time.now - time).to_i}s"
          @driver = driver
        rescue => error
          $logger.warn "Selenium driver failed to start in #{(Time.now - time).to_i}s"
          raise error
        end
      end
    end
  end
end
