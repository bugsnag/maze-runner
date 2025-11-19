require 'json'
require_relative '../../../test_helper'
require_relative '../../../../../lib/maze/api/model/span_set'

class SpanTest < Test::Unit::TestCase
  # Verifies that all fields and attributes are correctly parsed from a hash
  def test_span_from_hash
    # Load hash from file and create a populated span object
    test_file = File.read(File.join(__dir__, 'test_data', 'nested_spans_trace.json'))
    trace_hash = JSON.parse(test_file)
    span_set = Maze::Api::Model::SpanSet.from_trace_hash(trace_hash)

    assert_equal(21, span_set.size)
  end
end
