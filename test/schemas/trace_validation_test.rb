require 'test_helper'
require_relative '../../lib/maze/schemas/trace_validator'

class MockRequest
  attr_accessor :header
end

class TraceValidationTest < Test::Unit::TestCase

  def create_basic_request(body)
    request = MockRequest.new
    request.header = {
      'bugsnag-api-key' => ['12345678901234567890123456789012'],
      'bugsnag-sent-at' => ['2023-06-12T14:24:48.755Z'],
      'bugsnag-span-sampling' => ['0.1:4']
    }
    {
      :request => request,
      :body => body
    }
  end

  def test_sampling_span_regex
    regex = Regexp.new(Maze::Schemas::SAMPLING_HEADER)
    # assert_true(regex.match('0.0:1'))
    assert_not_nil(regex.match('0.1111:7'))
    assert_not_nil(regex.match('1:10'))
    assert_not_nil(regex.match('1.0:1'))
    assert_not_nil(regex.match('0:10'))
    assert_not_nil(regex.match('1:1'))
    assert_not_nil(regex.match('1:1;1:2;0.3:5'))

    assert_nil(regex.match('1,1'))
    assert_nil(regex.match('0..0:1'))
    assert_nil(regex.match('0.0:1.0'))
    assert_nil(regex.match('1.1:1'))
    assert_nil(regex.match('.0:3'))
    assert_nil(regex.match('1:1;;1:2'))
  end
  
  def test_valid_headers
    request = create_basic_request({ 'value' => 'abc123' })
    validator = Maze::Schemas::TraceValidator.new(request)
    validator.validate_headers
    assert_nil(validator.success)
    assert_equal(0, validator.errors.size, format_errors(validator.errors))
  end

  def test_invalid_bugsnag_api_key
    request = create_basic_request({ 'value' => 'abc123' })
    request[:request].header['bugsnag-api-key'] = ['bad api key']
    validator = Maze::Schemas::TraceValidator.new(request)
    validator.validate_headers
    assert_false(validator.success)
    assert_equal(1, validator.errors.size, format_errors(validator.errors))
    assert_equal("bugsnag-api-key header was expected to match the regex '^[A-Fa-f0-9]{32}$', but was 'bad api key'", validator.errors.first)
  end

  def test_invalid_bugsnag_sent_at
    request = create_basic_request({ 'value' => 'abc123' })
    request[:request].header['bugsnag-sent-at'] = ['having a bad time']
    validator = Maze::Schemas::TraceValidator.new(request)
    validator.validate_headers
    assert_false(validator.success)
    assert_equal(1, validator.errors.size, format_errors(validator.errors))
    assert_equal("bugsnag-sent-at header was expected to be an IOS 8601 date, but was 'having a bad time'", validator.errors.first)
  end

  def test_invalid_span_sampling
    request = create_basic_request({ 'value' => 'abc123' })
    request[:request].header['bugsnag-span-sampling'] = ['2:2']
    validator = Maze::Schemas::TraceValidator.new(request)
    validator.validate_headers
    assert_false(validator.success)
    assert_equal(1, validator.errors.size, format_errors(validator.errors))
    assert_equal("bugsnag-span-sampling header was expected to match the regex '^((1(.0)?|0(\\.[0-9]+)?):[0-9]+)(;((1(.0)?|0(\\.[0-9]+)?):[0-9]+))*$', but was '2:2'", validator.errors.first)
  end

  def test_regex_success
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({ 'value' => 'abc123' }))
    validator.regex_comparison('value', '[abc123]{6}')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def format_errors(errors)
    list = errors.join("\n")
    "Errors given:\n#{list}"
  end

  def test_regex_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => 'abc123'
    }))
    validator.regex_comparison('value', '[ab12]{6}')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to match the regex '[ab12]{6}', but was 'abc123'")
  end

  def test_element_int_in_range_success
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => 2
    }))
    validator.element_int_in_range('value', 1..3)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_element_int_in_range_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({ 'value' => 4 }))
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value':'4' was expected to be in the range '1..3'")
  end

  def test_element_int_in_range_no_int_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({ 'value' => 'abc' }))
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an integer, was 'abc'")
  end

  def test_contains_key_success
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => [
        {
          'key' => 'placeholder',
          'value' => {
            'stringValue' => 'none'
          }
        },
        {
          'key' => 'correct',
          'value' => {
            'stringValue' => 'done'
          }
        }
      ]
    }))
    validator.element_contains('value', 'correct')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_contains_key_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => [
        {
          'key' => 'placeholder',
          'value' => {
            'stringValue' => 'none'
          }
        },
        {
          'key' => 'correct',
          'value' => {
            'stringValue' => 'done'
          }
        }
      ]
    }))
    validator.element_contains('value', 'incorrect')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' did not contain a value with the key 'incorrect'")
  end

  def test_contains_not_array
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({ 'value' => '1234' }))
    validator.element_contains('value', 'incorrect')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an array, was '1234'")
  end

  def test_contains_key_value_and_options_success
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => [
        {
          'key' => 'placeholder',
          'value' => {
            'stringValue' => 'none'
          }
        },
        {
          'key' => 'correct',
          'value' => {
            'stringValue' => 'done'
          }
        }
      ]
    }))
    validator.element_contains('value', 'correct', 'stringValue', ['good', 'done'])
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_contains_key_value_and_options_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => [
        {
          'key' => 'placeholder',
          'value' => {
            'stringValue' => 'none'
          }
        },
        {
          'key' => 'correct',
          'value' => {
            'stringValue' => 'done'
          }
        }
      ]
    }))
    validator.element_contains('value', 'correct', 'stringValue', ['good', 'one'])
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value':'{\"key\"=>\"correct\", \"value\"=>{\"stringValue\"=>\"done\"}}' did not contain a value of 'stringValue' from '[\"good\", \"one\"]'")
  end

  def test_contains_key_value_and_options_value_type_missing_failure
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'value' => [
        {
          'key' => 'placeholder',
          'value' => {
            'stringValue' => 'none'
          }
        },
        {
          'key' => 'correct',
          'value' => {
            'stringValue' => 'done'
          }
        }
      ]
    }))
    validator.element_contains('value', 'correct', 'intValue', ['good', 'one'])
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value':'{\"key\"=>\"correct\", \"value\"=>{\"stringValue\"=>\"done\"}}' did not contain a value of 'intValue' from '[\"good\", \"one\"]'")
  end

  def test_greater_than_success
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('larger', 'smaller')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_success_equals
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('smaller', 'unit')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_failure_lesser
    validator = Maze::Schemas::TraceValidator.new(create_basic_request({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    }))
    validator.element_a_greater_or_equal_element_b('smaller', 'larger')
    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'smaller':'1' was expected to be greater than or equal to 'larger':'5'")
  end
end
