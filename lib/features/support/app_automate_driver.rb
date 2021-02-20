require 'appium_lib'
require 'open3'
require 'securerandom'
require_relative './fast_selenium'
require_relative './logger'
require_relative './maze_runner'

# Wraps Appium::Driver to enable control of a BrowserStack app-automate session
class AppAutomateDriver < Appium::Driver

  # @!attribute [r] device_type
  #   @return [String] The device, from the list of device capabilities, used for this test
  attr_reader :device_type

  # @!attribute [r] capabilities
  #   @return [Hash] The capabilities used to launch the BrowserStack instance
  attr_reader :capabilities

  # The App upload uri for BrowserStack App Automate
  BROWSER_STACK_APP_UPLOAD_URI = 'https://api-cloud.browserstack.com/app-automate/upload'

  # Creates the AppAutomateDriver
  #
  # @param username [String] the BrowserStack username
  # @param access_key [String] the BrowserStack access key
  # @param local_id [String] the identifier for the BrowserStackLocal tunnel
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param app_location [String] the location of the test-app to upload
  # @param locator [Symbol] the primary locator strategy Appium should use to find elements
  # @param additional_capabilities [Hash] a hash of additional capabilities to be used in this test run
  def initialize(username, access_key, local_id, target_device, app_location, locator = :id, additional_capabilities = {})
    MazeRunner.driver = self
    @device_type = target_device
    @element_locator = locator
    @access_key = access_key
    @local_id = local_id
    if app_location.start_with? 'bs://'
      app_url = app_location
    else
      app_url = upload_app(username, access_key, app_location)
      $logger.info "app uploaded to: #{app_url}"
      $logger.info 'You can use this url to avoid uploading the same app more than once.'
    end

    # Sets up identifiers for ease of connecting jobs
    name_capabilities = project_name_capabilities(target_device)

    $logger.info 'Appium driver initialised for:'
    $logger.info "    project : #{name_capabilities[:project]}"
    $logger.info "    build   : #{name_capabilities[:build]}"
    $logger.info "    name    : #{name_capabilities[:name]}"

    url = "https://app-automate.browserstack.com/dashboard/v2/search?query=#{build}&type=builds"
    if ENV['BUILDKITE']
      $logger.info Maze::LogUtil.linkify url, 'BrowserStack session(s)'
    else
      $logger.info "BrowserStack session(s): #{url}"
    end

    @capabilities = {
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': local_id,
      'browserstack.local': 'true',
      'autoAcceptAlerts': 'true',
      'app': app_url
    }
    @capabilities.merge! additional_capabilities
    @capabilities.merge! devices[target_device]
    @capabilities.merge! name_capabilities
    super({
      'caps' => @capabilities,
      'appium_lib' => {
        server_url: "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
      }
    }, true)
  end

  # Starts the BrowserStackLocal tunnel and the Appium driver
  def start_driver
    start_local_tunnel
    $logger.info 'Starting Appium driver'
    super
  end

  # Checks for an element, waiting until it is present or the method times out
  #
  # @param element_id [String] the element to search for using the @element_locator strategy
  # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
  # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
  def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout)
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

  # Clicks a given element
  #
  # @param element_id [String] the element to click using the @element_locator strategy
  def click_element(element_id)
    find_element(@element_locator, element_id).click
  end

  # Clears a given element
  #
  # @param element_id [String] the element to clear, found using the @element_locator strategy
  def clear_element(element_id)
    find_element(@element_locator, element_id).clear
  end

  # Sends keys to a given element
  #
  # @param element_id [String] the element to send text to using the @element_locator strategy
  # @param text [String] the text to send
  def send_keys_to_element(element_id, text)
    find_element(@element_locator, element_id).send_keys(text)
  end

  # Sends keys to a given element, clearing it first
  #
  # @param element_id [String] the element to clear and send text to using the @element_locator strategy
  # @param text [String] the text to send
  def clear_and_send_keys_to_element(element_id, text)
    element = find_element(@element_locator, element_id)
    element.clear
    element.send_keys(text)
  end

  # Reset the currently running application after a given timeout
  #
  # @param timeout [Number] the amount of time in seconds to wait before resetting
  def reset_with_timeout(timeout=0.1)
    sleep(timeout)
    reset
  end

  # Determines and returns sensible project, build, and name capabilities
  #
  # @param target_device [String] the device in the device list being targeted
  #
  # @return [Hash] A hash containing the 'project', 'build', and 'name' capabilities
  def project_name_capabilities(target_device)
    project = 'local'
    build = SecureRandom.uuid
    name = "#{target_device}"
    if ENV['BUILDKITE']
      bk_project = ENV['BUILDKITE_PIPELINE_NAME']

      bk_build_array = []
      bk_build_array << ENV['BUILDKITE_BUILD_NUMBER'] if ENV['BUILDKITE_BUILD_NUMBER']
      bk_build_array << ENV['BRANCH_NAME'] if ENV['BRANCH_NAME']
      bk_build = bk_build_array.join(' ')

      bk_name_array = [name]
      bk_name_array << ENV['BUILDKITE_STEP_KEY'] if ENV['BUILDKITE_STEP_KEY']
      bk_name_array << ENV['BUILDKITE_RETRY_COUNT'] if ENV['BUILDKITE_RETRY_COUNT']
      bk_name = bk_name_array.join(' ')

      project = bk_project unless bk_project.nil? or bk_project.empty?
      build = bk_build unless bk_build.nil? or bk_build.empty?
      name = bk_name
    end
    {
      project: project,
      build: build,
      name: name
    }
  end

  private

  def linkify(url, text)
    "\033]1339;url='#{url}';content='#{text}'\a"
  end

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
    $logger.info 'Starting BrowserStack local tunnel'
    status = nil
    bs_local = ENV['BROWSER_STACK_LOCAL'] || '/BrowserStackLocal'
    command = "#{bs_local} -d start --key #{@access_key} --local-identifier #{@local_id} --force-local"
    Open3.popen2(command) do |_stdin, _stdout, wait|
      status = wait.value
    end
    status
  end
end
