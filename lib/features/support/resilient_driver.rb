require 'appium_lib'
require_relative './fast_selenium'
require_relative './logger'

# Handles Appium driver restarts and retries in the case of failure. BrowserStack's iOS 10 and 11 iOS devices in
# particular seemed prone to the underlying Appium connection failing.
#
# For methods available on this class, @see AppAutomateDriver.
class ResilientAppiumDriver
  # Creates the AppiumDriver
  #
  # @param server_url [String] URL of the Appium server
  # @param app_location [String] URL or file location of the app to be used
  # @param capabilities [Hash] a hash of capabilities to be used in this test run
  def initialize(server_url, app_location, capabilities = {})
    @driver = AppiumDriver.new server_url,
                               app_location,
                               capabilities
  end

  def respond_to_missing?(method_name, include_private = false)
    @driver.respond_to_missing? method_name
  end

  def method_missing(method, *args, &block)
    return super unless @driver.respond_to?(method)

    retries = 0
    until retries >= 5
      begin
        return @driver.send(method, *args, &block)
      rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError => error
        retries += 1
        $logger.warn error
        $logger.warn 'Appium Error occurred - restarting driver.'
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
