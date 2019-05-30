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

  def test_defaults
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

  def test_upload_app_success
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
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_click_element_locator
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_wait_for_element_defaults
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true).at_least_once

    driver.expects(:find_element).with(:id, "test_button").returns(mocked_element).at_least_once

    response = driver.wait_for_element("test_button")
    assert(response, "The driver must return true if it finds an element")
  end

  def test_wait_for_element_locator
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true).at_least_once

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).at_least_once

    response = driver.wait_for_element("test_button")
    assert(response, "The driver must return true if it finds an element")
  end

  def test_wait_for_element_failure
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(false).at_least_once

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element).at_least_once

    response = driver.wait_for_element("test_button")
    assert_false(response, "The driver must return false if it does not find an element")
  end

  def test_send_keys_to_element_defaults
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with("Test_text")

    driver.expects(:find_element).with(:id, "test_text_entry").returns(mocked_element)

    driver.send_keys_to_element("test_text_entry", "Test_text")
  end

  def test_send_keys_to_element_locator
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with("Test_text")

    driver.expects(:find_element).with(:accessibility_id, "test_text_entry").returns(mocked_element)

    driver.send_keys_to_element("test_text_entry", "Test_text")
  end

  def test_start_driver
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    Appium::Driver.any_instance.expects(:start_driver)
    waiter = mock('Process::Waiter', value: mock('Process::Status'))
    Open3.expects(:popen2).with(LOCAL_TUNNEL_COMMAND).yields(mock('stdin'), mock('stdout'), waiter)

    driver.start_driver
  end
end

