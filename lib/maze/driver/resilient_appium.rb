require 'appium_lib'
require_relative '../logger'

module Maze
  module Driver
    # Handles Appium driver restarts and retries in the case of failure. BrowserStack's iOS 10 and 11 iOS devices in
    # particular seemed prone to the underlying Appium connection failing.
    #
    # For methods available on this class, @see AppAutomateDriver.
    class ResilientAppium
      # Creates the Appium Driver
      #
      # @param server_url [String] URL of the Appium server
      # @param capabilities [Hash] a hash of capabilities to be used in this test run
      # @param locator [Symbol] the primary locator strategy Appium should use to find elements
      def initialize(server_url, capabilities, locator = :id)
        @driver = Appium.new server_url,
                             capabilities,
                             locator
      end

      def respond_to_missing?(method_name, include_private = false)
        @driver.respond_to_missing? method_name, include_private
      end

      def method_missing(method, *args, &block)
        return super unless @driver.respond_to?(method)

        retries = 0
        until retries >= 5
          begin
            return @driver.send(method, *args, &block)
          rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError => error
            retries += 1
            $logger.warn 'Appium Error occurred - restarting driver:'
            $logger.warn error
            sleep 3
            restart
          end
        end

        # Re-raise the last error, although it might be better to re-raise the
        # first error instead.  Review based on whether we ever hit this.
        return if error.nil?

        $logger.error 'Maximum retries exceeded - raising the last error'
        raise error
      end
    end
  end
end
