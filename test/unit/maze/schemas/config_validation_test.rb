require_relative '../../test_helper'
require_relative '../../../../lib/maze/schemas/config_validator'

class MockRequest
  attr_accessor :header
end

class ConfigValidationTest < Test::Unit::TestCase

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

  def test_passing_block
    request = create_basic_request({'foo' => 'bar'})

    block_run = false

    test_block = Proc.new do |validator|
      block_run = true
      assert_equal(validator.headers, request[:request].header)
      assert_equal(validator.body, request[:body])
      assert(validator.success)
      assert(validator.errors.empty?)
    end

    validator = Maze::Schemas::ConfigValidator.new(request, test_block)
    validator.validate

    assert(block_run)
  end

  def test_basic_failing_block
    request = create_basic_request({ 'value' => 'abc' })

    block_run = false

    test_block = Proc.new do |validator|
      block_run = true
      validator.element_int_in_range('value', 1..3)
    end

    validator = Maze::Schemas::ConfigValidator.new(request, test_block)
    validator.validate

    assert(block_run)

    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be an integer, was 'abc'")
  end

  def test_custom_failing_block
    request = create_basic_request({ 'value' => 'abc' })

    block_run = false

    test_block = Proc.new do |validator|
      block_run = true
      test_val = Maze::Helper.read_key_path(validator.body, 'value')
      if test_val != 'abcd'
        validator.success = false
        validator.errors << "Element 'value' was expected to be 'abcd', was '#{test_val}'"
      end
    end

    validator = Maze::Schemas::ConfigValidator.new(request, test_block)
    validator.validate

    assert(block_run)

    assert_false(validator.success)
    assert_equal(1, validator.errors.size)
    assert_equal(validator.errors.first, "Element 'value' was expected to be 'abcd', was 'abc'")
  end
end