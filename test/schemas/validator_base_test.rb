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
end
