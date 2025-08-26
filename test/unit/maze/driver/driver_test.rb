# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../../lib/maze/driver/appium'

class AppiumDriverTest < Test::Unit::TestCase

  SERVER_URL = 'server_url'
  UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/.freeze

  def setup
    @capabilities = { key: 'value' }

    ENV.delete('BRANCH_NAME')
    ENV.delete('BUILDKITE')
    ENV.delete('BUILDKITE_PIPELINE_NAME')
    ENV.delete('BUILDKITE_BUILD_NUMBER')
    ENV.delete('BUILDKITE_RETRY_COUNT')
    ENV.delete('BUILDKITE_STEP_KEY')
  end

  def start_logger_mock
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock
  end

  def test_capabilities
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities
    assert_equal('value', driver.capabilities[:key])
  end

  def test_click_element_defaults
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:id, 'test_button').returns(mocked_element)

    driver.click_element('test_button')
  end

  def test_click_element_locator
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element)

    driver.click_element('test_button')
  end

  def test_click_element_if_present_success
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:click)

    driver.expects(:find_element).with(:id, 'test_button').returns(mocked_element)

    clicked = driver.click_element_if_present('test_button')
    assert_true clicked
  end

  def test_click_element_if_present_no_such_element
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    driver.expects(:find_element).with(:id, 'test_button').raises(Selenium::WebDriver::Error::NoSuchElementError)

    clicked = driver.click_element_if_present('test_button')
    assert_false clicked
  end

  def test_wait_for_element_defaults
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true)

    driver.expects(:find_element).with(:id, 'test_button').returns(mocked_element)

    response = driver.wait_for_element('test_button')
    assert(response, 'The driver must return true if it finds an element')
  end

  def test_wait_for_element_locator
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(true)

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element)

    response = driver.wait_for_element('test_button')
    assert(response, 'The driver must return true if it finds an element')
  end

  def test_wait_for_element_failure
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).returns(false).at_least_once

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element).at_least_once

    response = driver.wait_for_element('test_button', timeout = 1)
    assert_false(response, 'The driver must return false if it does not find an element')
  end

  def test_wait_for_element_stale_error_retry
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:displayed?).times(2).raises(Selenium::WebDriver::Error::StaleElementReferenceError, 'Element is stale').then.returns(true)

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element).times(2)

    response = driver.wait_for_element('test_button')
    assert(response, 'The driver must return true if it finds an element')
  end

  def test_wait_for_element_stale_error_retry_disabled
    logger = start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    stale_error = Selenium::WebDriver::Error::StaleElementReferenceError.new('Element is stale')
    mocked_element = mock('element')
    mocked_element.expects(:displayed?).once.raises(stale_error)

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element).once

    logger.expects(:warn).with("StaleElementReferenceError occurred: #{stale_error}")

    response = driver.wait_for_element('test_button', 15, false)
    assert_false(response, 'The driver must return false if it does not find an element')
  end

  def test_wait_for_element_stale_error_retry_only_once
    logger = start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    stale_error = Selenium::WebDriver::Error::StaleElementReferenceError.new('Element is stale')
    mocked_element = mock('element')
    mocked_element.expects(:displayed?).once.raises(stale_error)

    driver.expects(:find_element).with(:accessibility_id, 'test_button').returns(mocked_element).once

    logger.expects(:warn).with("StaleElementReferenceError occurred: #{stale_error}")

    response = driver.wait_for_element('test_button', 15, false)
    assert_false(response, 'The driver must return false if it does not find an element')
  ensure
    $logger = nil
  end

  def test_start_driver_success
    logger = start_logger_mock

    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    Appium::Driver.any_instance.expects(:start_driver).returns(true)
    Time.expects(:now).twice.returns(0)
    logger.expects(:info).with('Starting Appium driver...')
    logger.expects(:info).with('Appium driver started in 0s')

    driver.start_driver
  end
end

