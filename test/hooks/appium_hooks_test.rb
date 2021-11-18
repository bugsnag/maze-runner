# frozen_string_literal: true

require 'appium_lib'
require_relative '../test_helper'
require_relative '../../lib/maze/capabilities'
require_relative '../../lib/maze/driver/appium'
require_relative '../../lib/maze/driver/resilient_appium'
require_relative '../../lib/maze/hooks/appium_hooks'

class AppiumHooksTest < Test::Unit::TestCase

  def setup
    $logger = mock('logger')
    $config = mock('config')
    Maze.stubs(:config).returns($config)
  end

  def test_device_capabilities_bs
    $config.expects(:farm).returns(:bs)
    $config.expects(:device).returns(:device)
    $config.expects(:appium_version).returns(:appium_version)
    $config.expects(:capabilities_option).returns(:capabilities_option)
    $config.expects(:app).returns(:app)

    caps_base = {}

    Maze::Capabilities.expects(:for_browser_stack_device).with(
      :device,
      :tunnel_id,
      :appium_version,
      :capabilities_option
    ).returns(caps_base)

    hooks = Maze::Hooks::AppiumHooks.new
    caps = hooks.device_capabilities($config, :tunnel_id)
    assert_equal(caps, caps_base)
    assert_equal(:app, caps['app'])
  end

  def test_device_capabilities_local
    $config.expects(:farm).twice.returns(:local)
    $config.expects(:os).returns(:os)
    $config.expects(:capabilities_option).returns(:capabilities_option)
    $config.expects(:apple_team_id).returns(:apple_team_id)
    $config.expects(:device_id).returns(:device_id)
    $config.expects(:app).returns(:app)

    caps_base = {}

    Maze::Capabilities.expects(:for_local).with(
      :os,
      :capabilities_option,
      :apple_team_id,
      :device_id
    ).returns(caps_base)

    hooks = Maze::Hooks::AppiumHooks.new
    caps = hooks.device_capabilities($config)
    assert_equal(caps, caps_base)
    assert_equal(:app, caps['app'])
  end

  def test_create_driver_resilient
    $config.expects(:resilient).returns(true)
    $config.expects(:appium_server_url).returns(:appium_server_url)
    $config.expects(:capabilities).returns(:capabilities)
    $config.expects(:locator).returns(:locator)
    $logger.expects(:info).with('Creating ResilientAppium driver instance')

    Maze::Driver::ResilientAppium.expects(:new).with(
      :appium_server_url,
      :capabilities,
      :locator
    ).returns(:driver)

    hooks = Maze::Hooks::AppiumHooks.new
    driver = hooks.create_driver($config)

    assert_equal(:driver, driver)
  end

  def test_create_driver_default
    $config.expects(:resilient).returns(false)
    $config.expects(:appium_server_url).returns(:appium_server_url)
    $config.expects(:capabilities).returns(:capabilities)
    $config.expects(:locator).returns(:locator)
    $logger.expects(:info).with('Creating Appium driver instance')

    Maze::Driver::Appium.expects(:new).with(
      :appium_server_url,
      :capabilities,
      :locator
    ).returns(:driver)

    hooks = Maze::Hooks::AppiumHooks.new
    driver = hooks.create_driver($config)

    assert_equal(:driver, driver)
  end

  def test_start_driver_success
    driver_mock = mock('driver')
    driver_mock.expects(:start_driver)

    Maze.expects(:driver).twice.returns(false, true)
    Maze.expects(:driver=).with(driver_mock)

    hooks = Maze::Hooks::AppiumHooks.new
    hooks.expects(:device_capabilities).with($config, nil).returns(:caps)
    hooks.expects(:create_driver).with($config).returns(driver_mock)

    $config.expects(:capabilities=).with(:caps)
    $config.expects(:appium_session_isolation).returns(false)

    hooks.start_driver($config)
  end

  def test_start_driver_fails_once
    driver_mock = mock('driver')
    driver_mock.expects(:start_driver).raises(Selenium::WebDriver::Error::UnknownError)

    Maze.expects(:driver).returns(false)

    hooks = Maze::Hooks::AppiumHooks.new
    hooks.expects(:device_capabilities).with($config, nil).returns(:caps)
    hooks.expects(:create_driver).with($config).returns(driver_mock)

    $config.expects(:capabilities=).with(:caps)
    $config.expects(:appium_session_isolation).returns(false)
    $config.expects(:device).returns(:device)
    $config.expects(:farm).returns(:farm)
    $config.expects(:device_list).returns([])

    $logger.expects(:warn).with("Attempt to acquire #{:device} device from farm #{:farm} failed")
    $logger.expects(:warn).with("Exception: #{Selenium::WebDriver::Error::UnknownError.new.message}")
    $logger.expects(:error).with('No further devices to try - raising original exception')

    assert_raise Selenium::WebDriver::Error::UnknownError do
      hooks.start_driver($config)
    end
  end

  def test_start_driver_fails_then_succeeds
    driver_mock = mock('driver')
    driver_mock.expects(:start_driver).twice.raises(Selenium::WebDriver::Error::UnknownError).then.returns(true)

    Maze.expects(:driver).times(3).returns(false, false, true)

    hooks = Maze::Hooks::AppiumHooks.new
    hooks.expects(:device_capabilities).twice.with($config, nil).returns(:caps)
    hooks.expects(:create_driver).twice.with($config).returns(driver_mock)

    $config.expects(:capabilities=).twice.with(:caps)
    $config.expects(:appium_session_isolation).twice.returns(false)
    $config.expects(:device).twice.returns(:device)
    $config.expects(:farm).returns(:farm)
    device_list = mock('device_list')
    $config.stubs(:device_list).returns(device_list)
    $config.expects(:device_list=).with(device_list)
    $config.expects(:device=).with(:next_device)
    device_list.expects(:empty?).returns(false)
    device_list.expects(:first).returns(:next_device)
    device_list.expects(:drop).with(1).returns(device_list)

    $logger.expects(:warn).with("Attempt to acquire #{:device} device from farm #{:farm} failed")
    $logger.expects(:warn).with("Exception: #{Selenium::WebDriver::Error::UnknownError.new.message}")
    $logger.expects(:warn).with("Retrying driver initialisation using next device: #{:device}")

    Maze.expects(:driver=).with(driver_mock)

    hooks.start_driver($config)
  end

  def test_start_driver_fails_multiple_times
    driver_mock = mock('driver')
    driver_mock.expects(:start_driver).times(3).raises(Selenium::WebDriver::Error::UnknownError)

    Maze.expects(:driver).times(3).returns(false, false, false)

    hooks = Maze::Hooks::AppiumHooks.new
    hooks.expects(:device_capabilities).times(3).with($config, nil).returns(:caps)
    hooks.expects(:create_driver).times(3).with($config).returns(driver_mock)

    $config.expects(:capabilities=).times(3).with(:caps)
    $config.expects(:appium_session_isolation).times(3).returns(false)
    $config.expects(:device).times(5).returns(:device)
    $config.expects(:farm).times(3).returns(:farm)
    device_list = mock('device_list')
    $config.stubs(:device_list).returns(device_list)
    $config.expects(:device_list=).twice.with(device_list)
    $config.expects(:device=).twice.with(:next_device)
    device_list.expects(:empty?).times(3).returns(false, false, true)
    device_list.expects(:first).twice.returns(:next_device)
    device_list.expects(:drop).with(1).twice.returns(device_list)

    $logger.expects(:warn).times(3).with("Attempt to acquire #{:device} device from farm #{:farm} failed")
    $logger.expects(:warn).times(3).with("Exception: #{Selenium::WebDriver::Error::UnknownError.new.message}")
    $logger.expects(:warn).twice.with("Retrying driver initialisation using next device: #{:device}")
    $logger.expects(:error).with('No further devices to try - raising original exception')

    assert_raise Selenium::WebDriver::Error::UnknownError do
      hooks.start_driver($config)
    end
  end

  def test_start_driver_session_isolation
    driver_mock = mock('driver')

    Maze.expects(:driver).twice.returns(false, true)
    Maze.expects(:driver=).with(driver_mock)

    hooks = Maze::Hooks::AppiumHooks.new
    hooks.expects(:device_capabilities).with($config, nil).returns(:caps)
    hooks.expects(:create_driver).with($config).returns(driver_mock)

    $config.expects(:capabilities=).with(:caps)
    $config.expects(:appium_session_isolation).returns(true)

    hooks.start_driver($config)
  end

end