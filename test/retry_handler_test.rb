# frozen_string_literal: true

require 'test_helper'
require 'appium_lib'
require_relative '../lib/maze/errors'
require_relative '../lib/maze/retry_handler'
require_relative '../lib/maze/api/exit_code'
require_relative '../lib/maze/driver/appium'
require_relative '../lib/maze/driver/browser'
require_relative '../lib/maze/hooks/error_code_hook'

# noinspection RubyNilAnalysis
class RetryHandlerTest < Test::Unit::TestCase

  def setup
    @logger_mock = mock('logger')
    $logger = @logger_mock
    Maze::RetryHandler.instance_variable_set(:@global_retried, nil)
    @config_mock = mock('config')
    @config_mock.stubs(:enable_retries).returns(true)
    Maze.stubs(:config).returns(@config_mock)
  end

  def test_global_retried_default
    global_retried = Maze::RetryHandler.send(:global_retried)
    # Initial creation of `foo` entry
    assert_equal(global_retried['foo'], 0)
    # Asserting it hasn't been modified after creation
    assert_equal(global_retried['foo'], 0)
    assert_not_nil(global_retried['foo'])
  end

  def test_increment_retry_count
    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried['foo'], 0)

    Maze::RetryHandler.send(:increment_retry_count, 'foo')
    Maze::RetryHandler.send(:increment_retry_count, 'bar')

    assert_equal(global_retried['foo'], 1)
    assert_equal(global_retried['bar'], 1)
  end

  def test_retried_previously?
    global_retried = Maze::RetryHandler.send(:global_retried)
    Maze::RetryHandler.send(:increment_retry_count, 'foo')

    assert_true(Maze::RetryHandler.send(:retried_previously?, 'foo'))
    assert_false(Maze::RetryHandler.send(:retried_previously?, 'bar'))
  end

  def test_retry_on_tag_all_tags
    retry_tag = mock('retry_tag')
    retry_tag.expects(:name).returns('@retry')
    test_case_retry = mock('test_case')
    test_case_retry.expects(:tags).returns([retry_tag])

    assert_true(Maze::RetryHandler.send(:retry_on_tag?, test_case_retry))

    retryable_tag = mock('retryable_tag')
    retryable_tag.expects(:name).returns('@retryable')
    test_case_retryable = mock('test_case')
    test_case_retryable.expects(:tags).returns([retryable_tag])

    assert_true(Maze::RetryHandler.send(:retry_on_tag?, test_case_retryable))

    retriable_tag = mock('retriable_tag')
    retriable_tag.expects(:name).returns('@retriable')
    test_case_retriable = mock('test_case')
    test_case_retriable.expects(:tags).returns([retriable_tag])

    assert_true(Maze::RetryHandler.send(:retry_on_tag?, test_case_retriable))
  end

  def test_retry_on_tag_no_tags
    test_case_empty_array = mock('test_case')
    test_case_empty_array.expects(:tags).returns([])

    assert_false(Maze::RetryHandler.send(:retry_on_tag?, test_case_empty_array))

    skip_tag = mock('skip_tag')
    skip_tag.expects(:name).returns('@skip_android_10')
    test_case_invalid_tags = mock('test_case')
    test_case_invalid_tags.expects(:tags).returns([skip_tag])

    assert_false(Maze::RetryHandler.send(:retry_on_tag?, test_case_invalid_tags))
  end

  def test_retry_on_driver_no_maze_driver
    Maze.expects(:driver).returns(nil)

    result_mock = mock('result')
    result_mock.expects(:exception).returns(Selenium::WebDriver::Error::UnknownError.new)

    event_mock = mock('event')
    event_mock.expects(:result).returns(result_mock)

    assert_nil(Maze::RetryHandler.send(:retry_on_driver_error?, event_mock))
  end

  def test_retry_on_driver_errors
    Maze.expects(:driver).times(3).returns(true)

    result_unknown_mock = mock('result')
    result_unknown_mock.expects(:exception).returns(Selenium::WebDriver::Error::UnknownError.new)

    event_unknown_error_mock = mock('event')
    event_unknown_error_mock.expects(:result).returns(result_unknown_mock)

    assert_true(Maze::RetryHandler.send(:retry_on_driver_error?, event_unknown_error_mock))

    result_web_driver_mock = mock('result')
    result_web_driver_mock.expects(:exception).returns(Selenium::WebDriver::Error::WebDriverError.new)

    event_web_driver_error_mock = mock('event')
    event_web_driver_error_mock.expects(:result).returns(result_web_driver_mock)

    assert_true(Maze::RetryHandler.send(:retry_on_driver_error?, event_web_driver_error_mock))

    result_element_not_found_mock = mock('result')
    result_element_not_found_mock.expects(:exception).returns(Maze::Error::AppiumElementNotFoundError.new)

    event_element_not_found_mock = mock('event')
    event_element_not_found_mock.expects(:result).returns(result_element_not_found_mock)

    assert_true(Maze::RetryHandler.send(:retry_on_driver_error?, event_element_not_found_mock))
  end

  def test_retry_on_driver_error_wrong_error
    Maze.expects(:driver).returns(true)

    result_incorrect_mock = mock('result')
    result_incorrect_mock.expects(:exception).returns(RuntimeError.new)

    event_incorrect_error_mock = mock('event')
    event_incorrect_error_mock.expects(:result).returns(result_incorrect_mock)

    assert_false(Maze::RetryHandler.send(:retry_on_driver_error?, event_incorrect_error_mock))
  end

  def test_retry_on_driver_error_no_errors
    Maze.expects(:driver).returns(true)

    result_no_error_mock = mock('result')
    result_no_error_mock.expects(:exception).returns(nil)

    event_no_error_mock = mock('event')
    event_no_error_mock.expects(:result).returns(result_no_error_mock)

    assert_false(Maze::RetryHandler.send(:retry_on_driver_error?, event_no_error_mock))
  end

  def test_should_retry_appium_driver_not_bb_error
    driver_mock = mock('driver')
    Maze.expects(:driver).times(3).returns(driver_mock)
    driver_mock.expects(:is_a?).with(Maze::Driver::Appium).returns(true)
    driver_mock.expects(:restart)

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')

    error = Selenium::WebDriver::Error::UnknownError.new

    result_mock = mock('result')
    result_mock.expects(:exception).twice.returns(error)

    event_mock = mock('event')
    event_mock.expects(:result).twice.returns(result_mock)

    @logger_mock.expects('warn').with("Retrying test_case_mock due to appium driver error: #{error}")
    @config_mock.expects('farm').returns(:bs)

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 1)
  end

  def test_should_not_retry_appium_driver_bb_error
    driver_mock = mock('driver')
    Maze.expects(:driver).times(2).returns(driver_mock)
    driver_mock.expects(:is_a?).with(Maze::Driver::Appium).returns(true)

    test_case_mock = mock('test_case')

    error = Selenium::WebDriver::Error::UnknownError.new

    result_mock = mock('result')
    result_mock.expects(:exception).once.returns(error)

    event_mock = mock('event')
    event_mock.expects(:result).once.returns(result_mock)

    @config_mock.expects('farm').returns(:bb)

    Maze::Hooks::ErrorCodeHook.expects(:exit_code=).with(Maze::Api::ExitCode::APPIUM_SESSION_FAILURE)

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 0)
  end

  def test_should_retry_browser_driver_error
    driver_mock = mock('driver')
    Maze.expects(:driver).times(4).returns(driver_mock)
    driver_mock.expects(:is_a?).with(Maze::Driver::Appium).returns(false)
    driver_mock.expects(:is_a?).with(Maze::Driver::Browser).returns(true)
    driver_mock.expects(:refresh)

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')

    error = Selenium::WebDriver::Error::UnknownError.new

    result_mock = mock('result')
    result_mock.expects(:exception).twice.returns(error)

    event_mock = mock('event')
    event_mock.expects(:result).twice.returns(result_mock)

    @logger_mock.expects('warn').with("Retrying test_case_mock due to selenium driver error: #{error}")

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 1)
  end

  def test_should_retry_tag
    driver_mock = mock('driver')
    Maze.expects(:driver).returns(driver_mock)

    retry_tag = mock('retry_tag')
    retry_tag.expects(:name).returns('@retry')

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')
    test_case_mock.expects(:tags).returns([retry_tag])

    result_mock = mock('result')
    result_mock.expects(:exception).returns(nil)

    event_mock = mock('event')
    event_mock.expects(:result).returns(result_mock)

    @logger_mock.expects('warn').with("Retrying test_case_mock due to retry tag")

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 1)
  end

  def test_should_retry_invalid
    driver_mock = mock('driver')
    Maze.expects(:driver).returns(driver_mock)

    test_case_mock = mock('test_case')
    test_case_mock.expects(:tags).returns([])

    result_mock = mock('result')
    result_mock.expects(:exception).returns(nil)

    event_mock = mock('event')
    event_mock.expects(:result).returns(result_mock)

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 0)
  end

  def test_should_retry_repeated
    driver_mock = mock('driver')
    Maze.expects(:driver).returns(driver_mock)

    retry_tag = mock('retry_tag')
    retry_tag.expects(:name).returns('@retry')

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')
    test_case_mock.expects(:tags).returns([retry_tag])

    result_mock = mock('result')
    result_mock.expects(:exception).returns(nil)

    event_mock = mock('event')
    event_mock.expects(:result).returns(result_mock)

    @logger_mock.expects('warn').with("Retrying test_case_mock due to retry tag")

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))
  end

  def test_should_retry_disabled
    driver_mock = mock('driver')
    @config_mock.expects(:enable_retries).returns(false)

    test_case_mock = mock('test_case')
    event_mock = mock('event')

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock, event_mock))
  end
end
