# frozen_string_literal: true

require 'bugsnag'
require 'selenium-webdriver'

module Maze
  module Driver
    # Handles browser automation fundamentals
    class Browser
      # @!attribute [r] capabilities
      #   @return [Hash] The capabilities used to launch the BrowserStack instance
      attr_reader :capabilities

      def initialize(driver_for, selenium_url=nil, capabilities=nil)
        capabilities ||= {}
        @failed = false
        @capabilities = capabilities
        @driver_for = driver_for
        @selenium_url = selenium_url
      end

      # Whether the driver has known to have failed (it may still have failed and us not know yet)
      def failed?
        @failed
      end

      # Marks the driver as failed
      def fail_driver
        $logger.error 'Selenium driver failed, remaining scenarios will be skipped'
        @failed = true
      end

      def set_implicit_wait(timeout_seconds)
        @driver.manage.timeouts.implicit_wait = timeout_seconds
      rescue
        # Not all browsers support setting implicit wait
        $logger.warn 'Failed to set implicit wait on Selenium driver'
      end

      def find_element(*args)
        @driver.find_element(*args)
      end

      def wait_for_element(id)
        @driver.find_element(id: id)
      end

      def click_element(id)
        @driver.find_element(id: id).click
      end

      def navigate
        @driver.navigate
      end

      # Refreshes the page
      def refresh
        @driver.navigate.refresh
      end

      # Quits the driver
      def driver_quit
        @driver.quit
      end

      # check if Selenium supports running javascript in the current browser
      def javascript?
        !Maze.config.browser.nil? && @driver.execute_script('return true')
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

      # Restarts the underlying-driver in the case an unrecoverable error occurs
      #
      # @param attempts [Integer] The number of times we should retry a failed attempt (defaults to 6)
      def restart_driver(attempts=6)
        # Remove the old driver
        @driver.quit
        @driver = nil

        start_driver(attempts)
      end

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
          raise RuntimeError.new("Selenium driver failed to start in #{timeout} seconds")
        end
      end

      # Returns the driver session ID
      #
      # @returns [String] The session ID of the selenium session
      def session_id
        @driver.session_id
      end

      private

      # Creates and starts the selenium driver
      def create_driver(driver_for, selenium_url=nil)
        begin
          $logger.info "Starting Selenium driver"
          time = Time.now
          if driver_for == :remote
            driver = ::Selenium::WebDriver.for :remote,
                                               url: selenium_url,
                                               capabilities: @capabilities
          else
            if driver_for == :chrome
              options = Selenium::WebDriver::Options.chrome
            elsif driver_for == :firefox
              options = Selenium::WebDriver::Options.firefox
            end
            options.accept_insecure_certs = true
            driver = ::Selenium::WebDriver.for driver_for, options: options
          end
          $logger.info "Selenium driver started in #{(Time.now - time).to_i}s"
          @driver = driver
          @failed = false
        rescue => error
          Bugsnag.notify error
          $logger.warn "Selenium driver failed to start in #{(Time.now - time).to_i}s"
          raise error
        end
      end
    end
  end
end
