require 'appium_lib'
require 'open3'
require 'securerandom'
require_relative './fast_selenium'
require_relative './logger'
require_relative './maze_runner'

# Provide a thin layer of abstraction above @see Appium::Driver
class AppiumDriver < Appium::Driver

  # @!attribute [r] device_type
  #   @return [String] The device, from the list of device capabilities, used for this test
  attr_reader :device_type

  # @!attribute [r] capabilities
  #   @return [Hash] The capabilities used to launch the BrowserStack instance
  attr_reader :capabilities

  # Creates the AppiumDriver
  #
  # @param server_url [String] URL of the Appium server
  # @param target_device [String] a key from the Devices array selecting which device capabilities to target
  # @param capabilities [Hash] a hash of capabilities to be used in this test run
  def initialize(server_url, target_device, capabilities = {})
    MazeRunner.driver = self
    @device_type = target_device

    # Sets up identifiers for ease of connecting jobs
    name_capabilities = project_name_capabilities(target_device)

    $logger.info 'Appium driver initialised for:'
    $logger.info "    project : #{name_capabilities[:project]}"
    $logger.info "    build   : #{name_capabilities[:build]}"
    $logger.info "    name    : #{name_capabilities[:name]}"

    @capabilities = capabilities
        {
      # 'browserstack.console': 'errors',
      # 'browserstack.localIdentifier': local_id,
      # 'browserstack.local': 'true',
      # 'browserstack.networkLogs': 'true',
      'platformName': 'Android',
      'automationName': 'UiAutomator2',
      'autoAcceptAlerts': 'true',
      'app': 'features/fixtures/mazerunner/build/outputs/apk/release/mazerunner-release.apk'
    }
    @capabilities.merge! Devices::DEVICE_HASH[target_device]
    @capabilities.merge! name_capabilities
    super({
      'caps' => @capabilities,
      'appium_lib' => {
        server_url: 'http://localhost:4723/wd/hub'
      }
    }, true)
  end

  # Starts the BrowserStackLocal tunnel and the Appium driver
  def start_driver
    # start_local_tunnel
    $logger.info 'Starting Appium driver'
    super
  end

  # Checks for an element, waiting until it is present or the method times out
  #
  # @param element_id [String] the element to search for
  # @param timeout [Integer] the maximum time to wait for an element to be present in seconds
  # @param retry_if_stale [Boolean] enables the method to retry acquiring the element if a StaleObjectException occurs
  def wait_for_element(element_id, timeout = 15, retry_if_stale = true)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout)
    wait.until { find_element(:id, element_id).displayed? }
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
  # @param element_id [String] the element to click
  def click_element(element_id)
    find_element(:id, element_id).click
  end

  # Clears a given element
  #
  # @param element_id [String] the element to clear
  def clear_element(element_id)
    find_element(:id, element_id).clear
  end

  # Sends keys to a given element
  #
  # @param element_id [String] the element to send text to
  # @param text [String] the text to send
  def send_keys_to_element(element_id, text)
    find_element(:id, element_id).send_keys(text)
  end

  # Sends keys to a given element, clearing it first
  #
  # @param element_id [String] the element to clear and send text to
  # @param text [String] the text to send
  def clear_and_send_keys_to_element(element_id, text)
    element = find_element(:id, element_id)
    element.clear
    element.send_keys(text)
  end

  # Reset the currently running application after a given timeout
  #
  # @param timeout [Number] the amount of time in seconds to wait before resetting
  def reset_with_timeout(timeout = 0.1)
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
    name = target_device.to_s
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
end
