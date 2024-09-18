require 'test_helper'
require_relative '../../lib/maze/schemas/validator_base'

class MockRequest
  attr_accessor :header
end

class ValidatorBaseTest < Test::Unit::TestCase

  def setup
    Maze.config.span_timestamp_validation = true
  end

  def create_basic_request(body)
    request = MockRequest.new
    request.header = {
      'bugsnag-api-key' => ['12345678901234567890123456789012'],
      'bugsnag-sent-at' => ['2023-06-12T14:24:48.755Z']
    }
    {
      :request => request,
      :body => body
    }
  end

  def test_regex_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({ 'value' => 'abc123' }))
    validator.regex_comparison('value', '[abc123]{6}')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_regex_failure
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => 'abc123'
    }))
    validator.regex_comparison('value', '[ab12]{6}')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to match the regex '[ab12]{6}', but was 'abc123'")
  end

  def test_element_int_in_range_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => 2
    }))
    validator.element_int_in_range('value', 1..3)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_element_int_in_range_failure
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({ 'value' => 4 }))
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value':'4' was expected to be in the range '1..3'")
  end

  def test_element_int_in_range_no_int_failure
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({ 'value' => 'abc' }))
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an integer, was 'abc'")
  end

  def test_greater_than_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('larger', 'smaller')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_success_equals
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('smaller', 'unit')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_failure_lesser
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('smaller', 'larger')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'smaller':'1' was expected to be greater than or equal to 'larger':'5'")
  end

  def test_not_validate_timestamp
    Maze.config.span_timestamp_validation = false
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => '12345000000000'
    }))
    Time.expects(:now).never
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_validate_timestamp_success_exact
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => '12345000000000'
    }))
    Time.expects(:now).returns(12345)
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_validate_timestamp_success_within_tolerance
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => "#{30 * 60 * 1000 * 1000 * 1000}"
    }))
    Time.expects(:now).returns(0)
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_validate_timestamp_failure_invalid_type
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => 12345
    }))
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Timestamp was expected to be a string, was 'Integer'")
  end

  def test_validate_timestamp_failure_negative
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => '-1'
    }))
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Timestamp was expected to be a positive integer, was '-1'")
  end

  def test_validate_timestamp_failure_outside_tolerance
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'timestamp' => '12345000000000'
    }))
    Time.expects(:now).returns(12345 + 3601)
    validator.validate_timestamp('timestamp', Maze::Schemas::ValidatorBase::HOUR_TOLERANCE)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Timestamp was expected to be within 3600000000000 nanoseconds of the current time (15946000000000), was '12345000000000'")
  end

  def test_element_has_value_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => 'abc123'
    }))
    validator.element_has_value('value', 'abc123')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_element_has_value_is_nil
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => nil
    }))
    validator.element_has_value('value', 'abc123')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be 'abc123', was ''")
  end

  def test_element_has_value_is_wrong
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => '123abc'
    }))
    validator.element_has_value('value', 'abc123')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be 'abc123', was '123abc'")
  end

  def test_element_exists_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => '123abc',
      'array' => [1, 2, 3]
    }))
    validator.element_exists('value')
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size)

    validator.element_exists('array')
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size)
  end

  def test_element_exists_is_nil
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => '123abc',
      'array' => [1, 2, 3]
    }))
    validator.element_exists('missing')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'missing' was not found")
  end

  def test_element_exists_is_empty_array
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'value' => '123abc',
      'array' => []
    }))
    validator.element_exists('array')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'array' was an empty array")
  end

  def test_each_element_exists_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'foo' => 1,
      'bar' => 2
    }))
    validator.expects(:element_exists).with('foo').once
    validator.expects(:element_exists).with('bar').once
    validator.each_element_exists(['foo', 'bar'])
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size)
  end

  def test_each_element_exists_success_with_warning
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'foo' => 1,
      'bar' => 2
    }))
    validator.expects(:element_exists).with('foo').once
    logger_mock = mock('logger')
    logger_mock.expects(:warn).with("each_element_exists was called with a non-array value: 'foo'. Use element_exists instead.")
    $logger = logger_mock

    validator.each_element_exists('foo')
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size)
  end

  def test_each_element_contains_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'containers' => [
        { 'value' => 'abc' },
        { 'value' => 'def' },
        { 'value' => 'ghi' }
      ]
    }))
    validator.each_element_contains('containers', 'value')
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size)
  end

  def test_each_element_contains_mixed_success
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'containers' => [
        { 'value' => 'abc' },
        { 'value' => 'def' },
        { 'value' => 'ghi' },
        { 'not_value' => 'jkl' },
        { 'value' => nil },
        { 'value' => [] }
      ]
    }))
    validator.each_element_contains('containers', 'value')
    assert_false(validator.success)
    assert_equal(3, validator.errors.size)
    assert(validator.errors.include?("Required containers element value was not present at index 3"))
    assert(validator.errors.include?("Required containers element value was not present at index 4"))
    assert(validator.errors.include?("Required containers element value was not present at index 5"))
  end

  def test_each_element_contains_failures
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({
      'containers' => [
        { 'not_value' => 'jkl' }
      ]
    }))
    validator.each_element_contains('containers', 'value')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert(validator.errors.include?("Required containers element value was not present at index 0"))
  end

  def test_each_event_contains
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({}))
    validator.expects(:each_element_contains).with('events', 'val1').once
    validator.each_event_contains('val1')
  end

  def test_each_element_contains_each
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({}))
    validator.expects(:each_element_contains).with('containers', 'val1').once
    validator.expects(:each_element_contains).with('containers', 'val2').once
    validator.expects(:each_element_contains).with('containers', 'val3').once
    validator.each_element_contains_each('containers', ['val1', 'val2', 'val3'])
  end

  def test_each_event_contains_each
    validator = Maze::Schemas::ValidatorBase.new(create_basic_request({}))
    validator.expects(:each_event_contains).with('val1').once
    validator.expects(:each_event_contains).with('val2').once
    validator.expects(:each_event_contains).with('val3').once
    validator.each_event_contains_each(['val1', 'val2', 'val3'])
  end
end
