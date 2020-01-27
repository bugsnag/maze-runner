require 'appium_lib'
require 'open3'
require 'securerandom'
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
  # @param additional_capabilities [Hash] a hash of additional capabilities to be used in this test run
  def initialize(username, access_key, local_id, target_device, app_location, locator=:id, additional_capabilities={})
    @device_type = target_device
    @element_locator = locator
    @access_key = access_key
    @local_id = local_id
    app_url = upload_app(username, access_key, app_location)

    # Sets up identifiers for ease of connecting jobs
    project_id = ENV['BUILDKITE'] ? ENV['BUILDKITE_PIPELINE_NAME'] : "local"
    build_id = ENV['BUILDKITE'] ? "#{ENV['BUILDKITE_BRANCH']} #{ENV['BUILDKITE_BUILD_NUMBER']}" : SecureRandom.uuid
    build_name = "#{@device_type} #{ENV['BUILDKITE_RETRY_COUNT']}"

    $logger.warn "Appium driver initialised for:"
    $logger.warn "    project : #{project_id}"
    $logger.warn "    build   : #{build_id}"
    $logger.warn "    name    : #{build_name}"

    capabilities = {
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': local_id,
      'browserstack.local': 'true',
      'browserstack.networkLogs': 'true',
      'autoAcceptAlerts': 'true',
      'app': app_url,
      'project': project_id,
      'build': build_id,
      'name': build_name
    }
    capabilities.merge! additional_capabilities
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
  # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
  def wait_for_element(element_id, timeout=15, retry_if_stale=true)
    begin
      wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
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
