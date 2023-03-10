require 'test_helper'
require_relative '../../lib/maze/schemas/trace_validator'

class TraceValidationTest < Test::Unit::TestCase
  def test_initial_conditions
    validator = Maze::Schemas::TraceValidator.new({})
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_regex_success
    validator = Maze::Schemas::TraceValidator.new({
      'value' => 'abc123'
    })
    validator.regex_comparison('value', '[abc123]{6}')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_regex_failure
    validator = Maze::Schemas::TraceValidator.new({
      'value' => 'abc123'
    })
    validator.regex_comparison('value', '[ab12]{6}')
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value' was expected to match the regex '[ab12]{6}', but was 'abc123'")
  end

  def test_element_int_in_range_success
    validator = Maze::Schemas::TraceValidator.new({
      'value' => 2
    })
    validator.element_int_in_range('value', 1..3)
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_element_int_in_range_failure
    validator = Maze::Schemas::TraceValidator.new({
      'value' => 4
    })
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value':'4' was expected to be in the range '1..3'")
  end

  def test_element_int_in_range_no_int_failure
    validator = Maze::Schemas::TraceValidator.new({
      'value' => 'abc'
    })
    validator.element_int_in_range('value', 1..3)
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an integer, was 'abc'")
  end

  def test_contains_key_success
    validator = Maze::Schemas::TraceValidator.new({
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
    })
    validator.element_contains('value', 'correct')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_contains_key_failure
    validator = Maze::Schemas::TraceValidator.new({
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
    })
    validator.element_contains('value', 'incorrect')
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value' did not contain a value with the key 'incorrect'")
  end

  def test_contains_not_array
    validator = Maze::Schemas::TraceValidator.new({
      'value' => '1234'
    })
    validator.element_contains('value', 'incorrect')
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an array, was '1234'")
  end

  def test_contains_key_value_and_options_success
    validator = Maze::Schemas::TraceValidator.new({
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
    })
    validator.element_contains('value', 'correct', 'stringValue', ['good', 'done'])
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_contains_key_value_and_options_failure
    validator = Maze::Schemas::TraceValidator.new({
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
    })
    validator.element_contains('value', 'correct', 'stringValue', ['good', 'one'])
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value':'{\"key\"=>\"correct\", \"value\"=>{\"stringValue\"=>\"done\"}}' did not contain a value of 'stringValue' from '[\"good\", \"one\"]'")
  end

  def test_contains_key_value_and_options_value_type_missing_failure
    validator = Maze::Schemas::TraceValidator.new({
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
    })
    validator.element_contains('value', 'correct', 'intValue', ['good', 'one'])
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'value':'{\"key\"=>\"correct\", \"value\"=>{\"stringValue\"=>\"done\"}}' did not contain a value of 'intValue' from '[\"good\", \"one\"]'")
  end

  def test_greater_than_success
    validator = Maze::Schemas::TraceValidator.new({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    })
    validator.element_a_greater_or_equal_element_b('larger', 'smaller')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_success_equals
    validator = Maze::Schemas::TraceValidator.new({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    })
    validator.element_a_greater_or_equal_element_b('smaller', 'unit')
    assert_nil(validator.success)
    assert(validator.errors.empty?)
  end

  def test_greater_than_failure_lesser
    validator = Maze::Schemas::TraceValidator.new({
      'smaller' => 1,
      'unit' => 1,
      'larger' => 5
    })
    validator.element_a_greater_or_equal_element_b('smaller', 'larger')
    assert_false(validator.success)
    assert_equal(validator.errors.size, 1)
    assert_equal(validator.errors.first, "Element 'smaller':'1' was expected to be greater than or equal to 'larger':'5'")
  end
end
