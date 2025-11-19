require 'json'
require_relative '../../../test_helper'
require_relative '../../../../../lib/maze/api/model/span'
require_relative '../../../../../lib/maze/api/model/span_kind'

class SpanTest < Test::Unit::TestCase
  # Verifies that all fields and attributes are correctly parsed from a hash
  def test_span_from_hash
    # Load hash from file and create a populated span object
    test_file = File.read(File.join(__dir__, 'test_data', 'span_sample.json'))
    span_hash = JSON.parse(test_file)
    span = Maze::Api::Model::Span.from_hash(span_hash)

    # Verify each property of the span object created
    assert_equal('0e7d1dda40103863', span.id)
    assert_equal('CustomSpanAttributesScenarioSpan',  span.name)
    assert_equal(Maze::Api::Model::SpanKind::INTERNAL, span.kind)
    assert_equal('640363bdca12490dc93e9859b76a39fe', span.trace_id)
    assert_equal('1763554427680519000', span.start_time)
    assert_equal('1763554427682259000', span.end_time)

    # Verify attributes
    assert_equal(span.attributes.size, 7)

    key = 'bugsnag.span.category'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::STRING, span.attributes[key].type)
    assert_equal('custom', span.attributes[key].value)

    key = 'bugsnag.span.first_class'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::BOOL, span.attributes[key].type)
    assert_true(span.attributes[key].value)

    key = 'customAttribute1'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::STRING, span.attributes[key].type)
    assert_equal('C', span.attributes[key].value)

    key = 'customAttribute3'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::INT, span.attributes[key].type)
    assert_equal('3', span.attributes[key].value)

    key = 'bugsnag.sampling.p'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::DOUBLE, span.attributes[key].type)
    assert_equal(1.0, span.attributes[key].value)

    key = 'customAttribute4'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::DOUBLE, span.attributes[key].type)
    assert_equal(42.0, span.attributes[key].value)

    key = 'customAttribute5'
    assert_true(span.attributes.key?(key))
    assert_equal(key, span.attributes[key].key)
    assert_equal(Maze::Api::Model::SpanAttributeType::ARRAY, span.attributes[key].type)
    assert_kind_of(Array, span.attributes[key].value)

    # Array elements
    array = span.attributes[key].value
    assert_equal(4, array.size)
    assert_equal(Maze::Api::Model::SpanAttributeType::STRING, array[0].type)
    assert_equal('customString', array[0].value)
    assert_equal(Maze::Api::Model::SpanAttributeType::INT, array[1].type)
    assert_equal('42', array[1].value)
    assert_equal(Maze::Api::Model::SpanAttributeType::BOOL, array[2].type)
    assert_true(array[2].value)
    assert_equal(Maze::Api::Model::SpanAttributeType::DOUBLE, array[3].type)
    assert_equal(43.0, array[3].value)
  end
end
