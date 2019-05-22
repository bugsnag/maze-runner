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
  # @param username [String] the BrowserStack username
  # @param access_key [String] the BrowserStack access key
  # @param local_id [String] the identifier for the BrowserStackLocal tunnel
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param app_location [String] the location of the test-app to upload
  # @param locator [Symbol] the primary locator strategy Appium should use to find elements
  def initialize(username, access_key, local_id, target_device, app_location, locator=:id)
    @device_type = target_device
    @element_locator = locator
    @access_key = access_key
    @local_id = local_id
    app_url = upload_app(username, access_key, app_location)
    capabilities = {
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': local_id,
      'browserstack.local': 'true',
      'browserstack.networkLogs': 'true',
      'app' => app_url
    }
    capabilities.merge! devices[target_device]
    super({
      'caps' => capabilities,
      'appium_lib' => {
        :server_url => "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
      }
    }, true)
  end

  # Starts the BrowserStackLocal tunnel and the Appium driver
  def start_driver
    start_local_tunnel
    super
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

  # Sends keys to a given element
  #
  # @param element_id [String] the element to send text to using the @element_locator strategy
  # @param text [String] the text to send
  def send_keys_to_element(element_id, text)
    find_element(@element_locator, element_id).send_keys(text)
  end

  private

  def upload_app(username, access_key, app_location)
    res = `curl -u "#{username}:#{access_key}" -X POST "#{BROWSER_STACK_APP_UPLOAD_URI}" -F "file=@#{app_location}"`
    response = JSON.parse(res)
    if response.include?('error')
      raise "BrowserStack upload failed due to error: #{response['error']}"
    else
      response['app_url']
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
