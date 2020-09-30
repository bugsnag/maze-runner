require 'appium_lib'
require_relative './fast_selenium'
require_relative './logger'

# Handles Appium driver restarts and retries in the case of failure. BrowserStack's iOS 10 and 11 iOS devices in
# particular seemed prone to the underlying Appium connection failing.
#
# For methods available on this class, @see AppAutomateDriver.
class ResilientAppiumDriver
  # Creates the ResilientAppiumDriver
  #
  # @param username [String] the BrowserStack username
  # @param access_key [String] the BrowserStack access key
  # @param local_id [String] the identifier for the BrowserStackLocal tunnel
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param app_location [String] the location of the test-app to upload
  # @param locator [Symbol] the primary locator strategy Appium should use to find elements
  # @param additional_capabilities [Hash] a hash of additional capabilities to be used in this test run
  def initialize(username, access_key, local_id, target_device, app_location, locator = :id, additional_capabilities = {})
    @driver = AppAutomateDriver.new username,
                                    access_key,
                                    local_id,
                                    target_device,
                                    app_location,
                                    locator,
                                    additional_capabilities

    # This must appear after creation of @driver as AppAutomateDriver also does this
    MazeRunner.driver = self
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
