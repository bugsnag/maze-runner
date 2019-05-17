require 'appium_lib'
require 'open3'
require_relative './fast_selenium'

# Wraps Appium::Driver to enable control of a BrowserStack app-automate session
class AppAutomateDriver < Appium::Driver

  # @!attribute [r] device_type
  #   @return [String] The device, from the list of device capabilities, used for this test
  attr_reader :device_type

  # The App upload uri for BrowserStack App Automate
  BROWSER_STACK_APP_UPLOAD_URI = "https://api-cloud.browserstack.com/app-automate/upload"

  # Creates the AppAutomateDriver
  #
  # An instance of this driver should be assigned to the $driver variable for the steps to work correctly.
  # Adds an at_exit block to ensure a created driver is stopped
  #
  # @param username [String] the BrowserStack username
  # @param access_key [String] the BrowserStack access key
  # @param local_id [String] the identifier for the BrowserStackLocal tunnel
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param app_location [String] the location of the test-app to upload
  # @param locator [Symbol] the primary locator strategy Appium should use to find elements
  def initialize(username, access_key, local_id, target_device, app_location, locator=:id)
    @device_type = target_device
    @element_locator = locator
    app_url = upload_app(username, access_key, app_location)
    start_local_tunnel(access_key, local_id)
    capabilities = {
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': local_id,
      'browserstack.local': 'true',
      'browserstack.networkLogs': 'true'
    }
    capabilities.merge! devices[target_devices]
    super({
      'caps' => @capabilities,
      'appium_lib' => {
        :server_url => "http://#{@username}:#{@access_key}@hub-cloud.browserstack.com/wd/hub"
      }
    }, true)
    start_driver
  end

  # Checks for an element, waiting until it is present or the method times out
  #
  # @param element_id [String] the element to search for using the @element_locator strategy
  # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
  def wait_for_element(element_id, timeout=15)
    wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
    wait.until { find_element(@element_locator, element_id).displayed? }
  end

  # Clicks a given element
  #
  # @param element_id [String] the element to click using the @element_locator strategy
  def click_element(element_id)
    find_element(@element_locator, element_id).click
  end

  private

  def upload_app(username, access_key, app_location)
    res = `curl -u "#{username}:#{access_key}" -X POST "#{BROWSER_STACK_APP_UPLOAD_URI}" -F "file=@#{app_location}"`
    response = JSON.parse(res)
    if response.include?('error')
      raise Exception.new("BrowserStack upload failed due to error: #{response['error']}")
    else
      response['app_url']
    end
  end

  def devices
    Devices::DEVICE_HASH
  end

  def start_local_tunnel(access_key, local_id)
    status = nil
    Open3.popen2("/BrowserStackLocal -d start --key #{access_key} --local-identifier #{local_id} --force-local") do |stdin, stdout, wait|
      status = wait.value
    end
    status
  end
end
