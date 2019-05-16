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

  def test_default_assignments
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    assert_equal(USERNAME, driver.instance_variable_get( :@username ))
    assert_equal(ACCESS_KEY, driver.instance_variable_get( :@access_key ))
    assert_equal(LOCAL_ID, driver.instance_variable_get( :@local_id ))
    assert_equal(:id, driver.instance_variable_get( :@locator ))
    assert_equal({
      'browserstack.console': 'errors',
      'browserstack.localIdentifier': LOCAL_ID,
      'browserstack.local': 'true',
      'browserstack.networkLogs': 'true'
    }, driver.instance_variable_get( :@capabilities ))
  end

  def test_overridden_locator
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, :accessibility_id)
    assert_equal(:accessibility_id, driver.instance_variable_get( :@locator ))
  end

  def test_devices_source
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    assert_equal(Devices::DEVICE_HASH, driver.send(:devices))
  end

  def test_click_element_nil
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, true)

    driver.click_element("test_button")

    appium_mock.verify
  end

  def test_click_element_defaults
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, false)
    appium_mock.expect(:click, true)
    appium_mock.expect(:find_element, appium_mock) do |locator, element_id|
      locator == :id && element_id == "test_button"
    end

    driver.click_element("test_button")

    appium_mock.verify
  end

  def test_click_element_locator
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID, :accessibility_id)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, false)
    appium_mock.expect(:click, true)
    appium_mock.expect(:find_element, appium_mock) do |locator, element_id|
      locator == :accessibility_id && element_id == "test_button"
    end

    driver.click_element("test_button")

    appium_mock.verify
  end

  def test_background_app_nil
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, true)

    driver.background_app

    appium_mock.verify
  end

  def test_background_app_defaults
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, false)
    appium_mock.expect(:background_app, true) do |timeout|
      timeout == 3
    end

    driver.background_app

    appium_mock.verify
  end

  def test_background_app_custom_timeout
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, false)
    appium_mock.expect(:background_app, true) do |timeout|
      timeout == 5
    end

    driver.background_app(5)

    appium_mock.verify
  end

  def test_reset_app_nil
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, true)

    driver.reset_app

    appium_mock.verify
  end

  def test_reset_app
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    driver.instance_variable_set(:@driver, appium_mock)

    appium_mock.expect(:nil?, false)
    appium_mock.expect(:reset, true)

    driver.reset_app

    appium_mock.verify

  ensure
    driver.instance_variable_set(:@driver, nil)
  end

  def test_upload_app_success
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    appium_mock.expect(:nil?, false)
    driver.instance_variable_set(:@driver, appium_mock)

    json_response = JSON.dump({
      :app_url => "App_url"
    })

    command_call = Minitest::Mock.new
    command_call.expect(:call, json_response) do |cmd|
      cmd == %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    end
    driver.stub(:`, command_call) do
      driver.send(:upload_app, APP_LOCATION)
    end

    command_call.verify

    assert_equal(driver.instance_variable_get(:@capabilities)['app'], "App_url")
  end

  def test_upload_app_error
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    appium_mock.expect(:nil?, false)
    driver.instance_variable_set(:@driver, appium_mock)

    json_response = JSON.dump({
      :error => "Error"
    })

    command_call = Minitest::Mock.new
    command_call.expect(:call, json_response) do |cmd|
      cmd == %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    end
    driver.stub(:`, command_call) do
      begin
        driver.send(:upload_app, APP_LOCATION)
      rescue Exception => exception
        assert_equal("BrowserStack upload failed due to error: Error", exception.message)
      end
    end

    command_call.verify
  end

  def test_start_driver
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)
    appium_mock = Minitest::Mock.new
    appium_mock.expect(:start_driver, true)

    new_driver_call = Minitest::Mock.new
    new_driver_call.expect(:call, appium_mock) do |options, global|
      caps_valid = options['caps'] == {
        'browserstack.console': 'errors',
        'browserstack.localIdentifier': LOCAL_ID,
        'browserstack.local': 'true',
        'browserstack.networkLogs': 'true',
        'device' => 'Google Pixel 3',
        'platformName' => 'Android',
        'os' => 'android',
        'os_version' => '9.0'
      }
      appium_lib_valid = options['appium_lib'] == {
        :server_url => "http://#{USERNAME}:#{ACCESS_KEY}@hub-cloud.browserstack.com/wd/hub"
      }
      global_valid = !global
      caps_valid && appium_lib_valid && global_valid
    end

    Appium::Driver.stub(:new, new_driver_call) do
      driver.stub(:upload_app, true) do
        driver.stub(:start_local_tunnel, true) do
          driver.start_driver('ANDROID_9', APP_LOCATION)
        end
      end
    end

    appium_mock.verify
    new_driver_call.verify
  end

  def test_start_local_tunnel
    driver = AppAutomateDriver.new(USERNAME, ACCESS_KEY, LOCAL_ID)

    start_local_call = Minitest::Mock.new
    start_local_call.expect(:call, true) do |command|
      command == "/BrowserStackLocal -d start --key #{ACCESS_KEY} --local-identifier #{LOCAL_ID} --force-local"
    end

    Open3.stub(:popen2, start_local_call) do
      driver.send(:start_local_tunnel)
    end

    start_local_call.verify
  end
end

