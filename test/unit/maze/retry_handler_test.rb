# frozen_string_literal: true


require 'appium_lib_core'
require_relative '../test_helper'
require_relative '../../../lib/maze/api/exit_code'
require_relative '../../../lib/maze/errors'
require_relative '../../../lib/maze/retry_handler'
require_relative '../../../lib/maze/driver/appium'
require_relative '../../../lib/maze/driver/browser'
require_relative '../../../lib/maze/hooks/error_code_hook'

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

  def test_should_retry_tag
    retry_tag = mock('retry_tag')
    retry_tag.expects(:name).returns('@retry')

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')
    test_case_mock.expects(:tags).returns([retry_tag])

    @logger_mock.expects('warn').with("Retrying test_case_mock due to retry tag")

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 1)
  end

  def test_should_retry_invalid
    test_case_mock = mock('test_case')
    test_case_mock.expects(:tags).returns([])

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock))

    global_retried = Maze::RetryHandler.send(:global_retried)
    assert_equal(global_retried[test_case_mock], 0)
  end

  def test_should_retry_repeated
    retry_tag = mock('retry_tag')
    retry_tag.expects(:name).returns('@retry')

    test_case_mock = mock('test_case')
    test_case_mock.expects(:name).returns('test_case_mock')
    test_case_mock.expects(:tags).returns([retry_tag])

    @logger_mock.expects('warn').with("Retrying test_case_mock due to retry tag")

    assert_true(Maze::RetryHandler.should_retry?(test_case_mock))

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock))
  end

  def test_should_retry_disabled
    driver_mock = mock('driver')
    @config_mock.expects(:enable_retries).returns(false)

    test_case_mock = mock('test_case')

    assert_false(Maze::RetryHandler.should_retry?(test_case_mock))
  end
end
