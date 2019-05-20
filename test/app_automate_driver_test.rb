require 'test_helper'
require_relative '../lib/features/support/app_automate_driver'
require_relative '../lib/features/support/capabilities/devices'

# Ensure at_exit blocks are eaten
module Kernel
  alias_method :old_at_exit, :at_exit
  def at_exit
  end
end


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

    assert_equal(ACCESS_KEY, driver.instance_variable_get(:@access_key))
    assert_equal(:id, driver.instance_variable_get(:@element_locator))
    assert_equal(TARGET_DEVICE, driver.instance_variable_get(:@device_type))
    assert_equal(LOCAL_ID, driver.instance_variable_get(:@local_id))
    assert_equal('errors', driver.caps[:'browserstack.console'])
    assert_equal(LOCAL_ID, driver.caps[:'browserstack.localIdentifier'])
    assert_equal('true', driver.caps[:'browserstack.local'])
    assert_equal('true', driver.caps[:'browserstack.networkLogs'])
    assert_equal(TEST_APP_URL, driver.caps[:app])

    Devices::DEVICE_HASH[TARGET_DEVICE].each do |key, value|
      assert_equal(value, driver.caps[key.to_sym])
    end
  end

  def test_overridden_location
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    assert_equal(ACCESS_KEY, driver.instance_variable_get(:@access_key))
    assert_equal(:accessibility_id, driver.instance_variable_get(:@element_locator))
    assert_equal(TARGET_DEVICE, driver.instance_variable_get(:@device_type))
    assert_equal(LOCAL_ID, driver.instance_variable_get(:@local_id))
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
    AppAutomateDriver.any_instance.stubs(:`).returns(json_response)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)
    assert_equal(TEST_APP_URL, driver.caps[:app])
  end

  def test_upload_app_error
    json_response = JSON.dump({
      :error => "Error"
    })
    AppAutomateDriver.any_instance.stubs(:`).returns(json_response)
    begin
      driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)
    rescue Exception => exception
      assert_equal("BrowserStack upload failed due to error: Error", exception.message)
    end
  end

  def test_click_element_defaults
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    mocked_element = mock('object')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_click_element_locator
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION, :accessibility_id)

    mocked_element = mock('object')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:accessibility_id, "test_button").returns(mocked_element)

    driver.click_element("test_button")
  end

  def test_start_driver
    AppAutomateDriver.any_instance.stubs(:upload_app).returns(TEST_APP_URL)
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, TARGET_DEVICE, APP_LOCATION)

    Appium::Driver.any_instance.expects(:start_driver)
    Open3.expects(:popen2).with(LOCAL_TUNNEL_COMMAND)

    driver.start_driver
  end
end

