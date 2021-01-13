# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/maze/driver/appium'

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
    logger_mock.expects(:info).with('Appium driver initialized for:').once
    logger_mock.expects(:info).with('    project : local').once
    logger_mock.expects(:info).with(regexp_matches(/^\s{4}build\s{3}:\s\S{36}$/))
    logger_mock
  end

  def test_capabilities
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities
    assert_equal('value', driver.caps[:key])
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

  def test_clear_element_defaults
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:clear)

    driver.expects(:find_element).with(:id, 'test_text_entry').returns(mocked_element)

    driver.clear_element('test_text_entry')
  end

  def test_send_keys_to_element_defaults
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with('Test_text')

    driver.expects(:find_element).with(:id, 'test_text_entry').returns(mocked_element)

    driver.send_keys_to_element('test_text_entry', 'Test_text')
  end

  def test_clear_and_send_keys_to_element_defaults
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities

    mocked_element = mock('element')
    mocked_element.expects(:clear)
    mocked_element.expects(:send_keys).with('Test_text')

    driver.expects(:find_element).with(:id, 'test_text_entry').returns(mocked_element)

    driver.clear_and_send_keys_to_element('test_text_entry', 'Test_text')
  end

  def test_clear_element_locator
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:clear)

    driver.expects(:find_element).with(:accessibility_id, 'test_text_entry').returns(mocked_element)

    driver.clear_element('test_text_entry')
  end

  def test_send_keys_to_element_locator
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:send_keys).with('Test_text')

    driver.expects(:find_element).with(:accessibility_id, 'test_text_entry').returns(mocked_element)

    driver.send_keys_to_element('test_text_entry', 'Test_text')
  end

  def test_clear_and_send_keys_to_element_locator
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    mocked_element = mock('element')
    mocked_element.expects(:clear)
    mocked_element.expects(:send_keys).with('Test_text')

    driver.expects(:find_element).with(:accessibility_id, 'test_text_entry').returns(mocked_element)

    driver.clear_and_send_keys_to_element('test_text_entry', 'Test_text')
  end

  def test_project_name_capabilities_local
    # BUILDKITE environment variable is cleared in setup
    start_logger_mock
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id
    hash = driver.project_name_capabilities

    assert_equal 'local', hash[:project]
    assert_match UUID_REGEX, hash[:build]
  end

  def test_project_name_capabilities_browser_stack
    start_logger_mock

    pipeline = 'Android Bugsnag Notifier'
    driver = Maze::Driver::Appium.new SERVER_URL, @capabilities, :accessibility_id

    ENV['BUILDKITE'] = 'true'
    ENV['BUILDKITE_PIPELINE_NAME'] = pipeline
    hash = driver.project_name_capabilities

    assert_equal pipeline, hash[:project]
    assert_match UUID_REGEX, hash[:build]
  end
end

