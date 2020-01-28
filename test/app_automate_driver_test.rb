require 'test_helper'
require_relative '../lib/features/support/app_automate_driver'
require_relative '../lib/features/support/capabilities/devices'

class AppAutomateDriverTest < Test::Unit::TestCase

  USERNAME = "Username"
  ACCESS_KEY = "Access_key"
  LOCAL_ID = "Local_id"
  APP_LOCATION = "App_location"
  TEST_APP_URL = "Test_app_url"
  TARGET_DEVICE = "ANDROID_9"
  LOCAL_TUNNEL_COMMAND = "/BrowserStackLocal -d start --key #{ACCESS_KEY} --local-identifier #{LOCAL_ID} --force-local"

  def setup
    ENV.delete("BUILDKITE")
    ENV.delete("BUILDKITE_PIPELINE_NAME")
    ENV.delete("BUILDKITE_BRANCH")
    ENV.delete("BUILDKITE_BUILD_NUMBER")
    ENV.delete("BUILDKITE_RETRY_COUNT")
    ENV.delete("BUILDKITE_STEP_KEY")
  end

  def start_logger_mock
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock.expects(:warn).with("Appium driver initialised for:").once
    logger_mock.expects(:warn).with("    project : local").once
    logger_mock.expects(:warn).with(regexp_matches(/^\s{4}build\s{3}:\s\S{36}$/))
    logger_mock.expects(:warn).with(regexp_matches(/^\s{4}name\s{4}:\s.+$/))
    logger_mock
  end

  def test_defaults
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    assert_equal('errors', driver.caps[:'browserstack.console'])
    assert_equal(LOCAL_ID, driver.caps[:'browserstack.localIdentifier'])
    assert_equal('true', driver.caps[:'browserstack.local'])
    assert_equal('true', driver.caps[:'browserstack.networkLogs'])
    assert_equal(TEST_APP_URL, driver.caps[:app])

    Devices::DEVICE_HASH[TARGET_DEVICE].each do |key, value|
      assert_equal(value, driver.caps[key.to_sym])
    end
  end

  def test_overridden_locator
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    assert_equal('errors', driver.caps[:'browserstack.console'])
    assert_equal(LOCAL_ID, driver.caps[:'browserstack.localIdentifier'])
    assert_equal('true', driver.caps[:'browserstack.local'])
    assert_equal('true', driver.caps[:'browserstack.networkLogs'])
    assert_equal(TEST_APP_URL, driver.caps[:app])

    Devices::DEVICE_HASH[TARGET_DEVICE].each do |key, value|
      assert_equal(value, driver.caps[key.to_sym])
    end
  end

  def test_add_capabilities
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    added_capabilities = {
      "automationName" => "Appium"
    }
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :id, added_capabilities)

    assert_equal('errors', driver.caps[:'browserstack.console'])
    assert_equal(LOCAL_ID, driver.caps[:'browserstack.localIdentifier'])
    assert_equal('true', driver.caps[:'browserstack.local'])
    assert_equal('true', driver.caps[:'browserstack.networkLogs'])
    assert_equal(TEST_APP_URL, driver.caps[:app])

    Devices::DEVICE_HASH[TARGET_DEVICE].each do |key, value|
      assert_equal(value, driver.caps[key.to_sym])
    end

    assert_equal('Appium', driver.caps[:automationName])
  end

  def test_upload_app_success
    start_logger_mock
    json_response = JSON.dump({
      :app_url => TEST_APP_URL
    })
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    AppAutomateDriver.any_instance.stubs(:`).with(expected_command).returns(json_response)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)
    assert_equal(TEST_APP_URL, driver.caps[:app])
  end

  def test_upload_app_error
    json_response = JSON.dump({
      :error => "Error"
    })
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    AppAutomateDriver.any_instance.stubs(:`).with(expected_command).returns(json_response)
    assert_raise(RuntimeError, "BrowserStack upload failed due to error: Error") do
      AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)
    end
  end

  def test_click_element_defaults
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_click_element_locator
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_wait_for_element_defaults
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true)

    driver.expects(:find_element).with(:id, "test_button").returns(mocked_element)

    response = driver.wait_for_element("test_button")
    assert(response, "The driver must return true if it finds an element")
  end

  def test_wait_for_element_locator
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element)

    response = driver.wait_for_element("test_button")
    assert(response, "The driver must return true if it finds an element")
  end

  def test_wait_for_element_failure
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(false).at_least_once

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).at_least_once

    response = driver.wait_for_element("test_button")
    assert_false(response, "The driver must return false if it does not find an element")
  end

  def test_wait_for_element_stale_error_retry
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).times(2).raises(Selenium::WebDriver::Error::StaleElementReferenceError, 'Element is stale').then.returns(true)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).times(2)

    response = driver.wait_for_element("test_button")
    assert(response, "The driver must return true if it finds an element")
  end

  def test_wait_for_element_stale_error_retry_disabled
    logger = start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    stale_error = Selenium::WebDriver::Error::StaleElementReferenceError.new("Element is stale")
    mocked_element = mock('element')
    mocked_element.expects(:displayed?).once.raises(stale_error)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).once

    logger.expects(:warn).with("StaleElementReferenceError occurred: #{stale_error}")

    response = driver.wait_for_element("test_button", 15, false)
    assert_false(response, "The driver must return false if it does not find an element")
  end

  def test_wait_for_element_stale_error_retry_only_once
    logger = start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    stale_error = Selenium::WebDriver::Error::StaleElementReferenceError.new("Element is stale")
    mocked_element = mock('element')
    mocked_element.expects(:displayed?).once.raises(stale_error)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).once

    logger.expects(:warn).with("StaleElementReferenceError occurred: #{stale_error}")

    response = driver.wait_for_element("test_button", 15, false)
    assert_false(response, "The driver must return false if it does not find an element")
  ensure
    $logger = nil
  end

  def test_send_keys_to_element_defaults
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with("Test_text")

    driver.expects(:find_element).with(:id, "test_text_entry").returns(mocked_element)

    driver.send_keys_to_element("test_text_entry", "Test_text")
  end

  def test_send_keys_to_element_locator
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with("Test_text")

    driver.expects(:find_element).with(:accessibility_id, "test_text_entry").returns(mocked_element)

    driver.send_keys_to_element("test_text_entry", "Test_text")
  end

  def test_start_driver
    start_logger_mock
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    Appium::Driver.any_instance.expects(:start_driver)
    waiter = mock('Process::Waiter', value: mock('Process::Status'))
    Open3.expects(:popen2).with(LOCAL_TUNNEL_COMMAND).yields(mock('stdin'), mock('stdout'), waiter)

    driver.start_driver
  end

  def test_environment_ids
    ENV["BUILDKITE"] = "true"
    ENV["BUILDKITE_PIPELINE_NAME"] = "TEST"
    ENV["BUILDKITE_BRANCH"] = "TEST BRANCH"
    ENV["BUILDKITE_BUILD_NUMBER"] = "156"
    ENV["BUILDKITE_RETRY_COUNT"] = "5"
    ENV["BUILDKITE_STEP_KEY"] = "tests-05"
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock.expects(:warn).with("Appium driver initialised for:").once
    logger_mock.expects(:warn).with("    project : TEST").once
    logger_mock.expects(:warn).with("    build   : TEST BRANCH 156")
    logger_mock.expects(:warn).with("    name    : #{TARGET_DEVICE} tests-05 5")

    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    assert_equal('TEST', driver.caps[:project])
    assert_equal('TEST BRANCH 156', driver.caps[:build])
    assert_equal("#{TARGET_DEVICE} tests-05 5", driver.caps[:name])
  end
end

