require 'appium_lib'
require_relative './fast_selenium'
require_relative './logger'

# Handles Appium driver restarts and retries in the case of failure
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
  end

  def respond_to_missing?(method_name, include_private = false)
    @driver.respond_to_missing? method_name
  end

  def method_missing(method, *args, &block)
    return super unless @driver.respond_to?(method)

    retries = 0
    until retries >= 5
      begin
        @driver.send(method, *args, &block)
        return
      rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::WebDriverError => error
        retries += 1
        recover
      end
    end

    # Re-raise the last error, although it might be better to re-raise the
    # first error instead.  Review based on whther we ever hit this.
    raise error unless error.nil?
  end

  private

  # Restarts the underlying driver and calls the block given.
  def recover
    # BrowserStack's iOS 10 and 11 iOS devices seemed prone to the underlying Appium connection failing.
    # There is potential for an infinite loop here, but in reality a single restart seems
    # sufficient each time the error occurs.  CI step timeouts are also in place to guard
    # against an infinite loop.
    $logger.warn 'Appium Error occurred - restarting driver.'
    restart
    sleep 5 # Only to avoid a possible tight loop
    yield
  end
end
