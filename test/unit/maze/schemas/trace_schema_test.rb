require 'json_schemer'
require 'json'
require_relative '../../test_helper'
require_relative '../../../../lib/maze/schemas/trace_schema'

class TraceValidationTest < Test::Unit::TestCase
  def message_for(error)
    JSONSchemer::Errors.pretty(error)
  end

  def validate(input_file)
    file_path = File.join(File.dirname(__FILE__), 'test_data', input_file)
    payload = JSON.parse(File.open(file_path, &:read))
    schema = JSONSchemer.schema(Maze::Schemas::TRACE_SCHEMA)
    schema.validate(payload)
  end

  def test_valid_trace
    schema_errors = validate('valid_trace.json')
    assert_equal(0, schema_errors.to_a.size)
  end

  def test_invalid_spans
    schema_errors = validate('invalid_spans.json')
    errors = schema_errors.map { |error| message_for(error) }.to_set
    assert_equal(2, errors.size)
    assert_includes(errors, 'property \'/resourceSpans/0/scopeSpans/0/spans/1/spanId\' does not match pattern: ^[0-9a-fA-F]{16}$')
    assert_includes(errors, 'property \'/resourceSpans/0/scopeSpans/0/spans/2/traceId\' does not match pattern: ^[0-9a-fA-F]{32}$')
  end
end
