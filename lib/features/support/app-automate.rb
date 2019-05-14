require 'appium_lib'
require 'open3'

# Wraps Appium::Driver to enable control of a BrowserStack app-automate session
class AppAutomateDriver

  # @!attribute [r] device_type
  #   @return [String] The device, from the list of device capabilities, used for this test
  attr_reader :device_type

  # @!attribute [r] driver
  #   @return [Object, nil] The driver being used
  attr_reader :driver

  # @!attribute capabilities
  #   @return [Hash] A hash of capabilities used by the driver
  attr_accessor :capabilities

  # The App upload uri for BrowserStack App Automate
  APP_UPLOAD_URI = "https://api-cloud.browserstack.com/app-automate/upload"

  # Creates the AppAutomateDriver
  #
  # An instance of this driver should be assigned to the $driver variable for the steps to work correctly.
  # Adds an at_exit block to ensure a created driver is stopped
  #
  # @param username [String] the BrowserStack username
  # @param access_key [String] the BrowserStack access key
  # @param local_id [String] the identifier for the BrowserStackLocal tunnel
  # @param locator [Symbol] the primary locator strategy Appium should use to find elements
  def initialize(username, access_key, local_id, locator=:id)
    @username = username
    @access_key = access_key
    @local_id = local_id
    @capabilities = {
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': local_id,
      'browserstack.local': 'true',
      'browserstack.networkLogs': 'true'
    }
    @locator = locator

    at_exit do
      @driver.quit unless @driver.nil?
    end
  end

  # Initialises the BrowserStack app-automate connect by:
  #   Uploading the app file
  #   Starting the BrowserStackLocal tunnel
  #   Creates and starts the Appium driver
  #
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param app_location [String] the location of the test-app to upload
  def start_driver(target_device, app_location)
    @device_type = target_device
    upload_app(app_location)
    start_local_tunnel
    @capabilities.merge! devices[target_device]
    @driver = Appium::Driver.new({
      'caps' => @capabilities,
      'appium_lib' => {
        :server_url => "http://#{@username}:#{@access_key}@hub-cloud.browserstack.com/wd/hub"
      }
    }, false).start_driver
  end

  # Checks for an element, waiting until it is present or the method times out
  #
  # @param element_id [String] the element to search for using the @locator strategy
  # @param timeout [Integer] the maximum time to wait for an element to be present
  def wait_for_element(element_id, timeout=15)
    unless @driver.nil?
      wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
      wait.until { @driver.find_element(@locator, element_id).displayed? }
    end
  end

  # Clicks a given element
  #
  # @param element_id [String] the element to click using the @locator strategy
  def click_element(element_id)
    @driver.find_element(@locator, element_id).click unless @driver.nil?
  end

  # Sends the application to the background for time before resuming
  #
  # @param timeout [Integer] the amount of time the app should be in the background
  def background_app(timeout=3)
    @driver.background_app(timeout) unless @driver.nil?
  end

  # Removes all application data and relaunches the app
  def reset_app
    @driver.reset unless @driver.nil?
  end

  private

  def upload_app(app_location)
    res = `curl -u "#{@username}:#{@access_key}" -X POST "#{APP_UPLOAD_URI}" -F "file=@#{app_location}"`
    resData = JSON.parse(res)
    if resData.include?('error')
      raise Exception.new("BrowserStack upload failed due to error: #{resData['error']}")
    else
      @capabilities['app'] = resData['app_url']
    end
  end

  def devices
    Devices::DEVICE_HASH
  end

  def start_local_tunnel
    status = nil
    Open3.popen2("/BrowserStackLocal -d start --key #{@access_key} --local-identifier #{@local_id} --force-local") do |stdin, stdout, wait|
      status = wait.value
    end
    status
  end
end
