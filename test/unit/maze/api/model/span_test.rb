require 'json'
require_relative '../../../test_helper'
require_relative '../../../../../lib/maze/api/model/span'

class SpanTest < Test::Unit::TestCase
  def test_span_from_hash
    # Load hash from file and create a populated span object
    test_file = File.read(File.join(__dir__, 'test_data', 'span_sample.json'))
    span_hash = JSON.parse(test_file)
    span = Maze::Api::Model::Span.from_hash(span_hash)

    # Verify each property of the span object created
    assert_equal('0e7d1dda40103863', span.id)
  end
end
