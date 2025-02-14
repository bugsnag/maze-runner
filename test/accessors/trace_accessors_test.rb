# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/accessors/trace_accessors'
require_relative '../../lib/maze/helper'
require_relative '../../lib/maze/server'

class TraceAccessorsTest < Test::Unit::TestCase

  ATTRIBUTE_LIST = {
    'resource' => {
      'attributes' => [
        {
          'key' => 'string.value',
          'value' => {
            'stringValue' => 'STRING'
          }
        }
      ]
    }
  }

  def test_attribute_by_key_success
    list_mock = mock('test_list')
    list_mock.expects('current').once.returns({
      :body => ATTRIBUTE_LIST
    })
    Maze::Server.expects(:list_for).with('test').returns(list_mock)
    attribute = Maze::Accessors::TraceAccessors.attribute_by_key('test', 'resource', 'string.value')
    assert_equal({
      'key' => 'string.value',
      'value' => {
        'stringValue' => 'STRING'
      }
    }, attribute)
  end

  def test_attribute_by_key_field_missing
    list_mock = mock('test_list')
    list_mock.expects('current').once.returns({
      :body => ATTRIBUTE_LIST
    })
    Maze::Server.expects(:list_for).with('test').returns(list_mock)
    attribute = Maze::Accessors::TraceAccessors.attribute_by_key('test', 'not_found', 'string.value')
    assert_nil(attribute)
  end

  def test_attribute_by_key_attribute_missing
    list_mock = mock('test_list')
    list_mock.expects('current').once.returns({
      :body => ATTRIBUTE_LIST
    })
    Maze::Server.expects(:list_for).with('test').returns(list_mock)
    attribute = Maze::Accessors::TraceAccessors.attribute_by_key('test', 'resource', 'not_found')
    assert_nil(attribute)
  end

  def test_attribute_value_matches_success
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'stringValue' => 'STRING'
      },
      'stringValue',
      'STRING'
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'intValue' => '123456'
    },
      'intValue',
      123456
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'bytesValue' => 'BYTES'
    },
      'bytesValue',
      'BYTES'
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => 'false'
    },
      'boolValue',
      false
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => 'true'
    },
      'boolValue',
      true
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => true
    },
      'boolValue',
      true
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => false
    },
      'boolValue',
      'false'
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => true
    },
      'boolValue',
      true
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'doubleValue' => '1.52'
      },
      'doubleValue',
      1.52
    ))
    assert(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'arrayValue' => {
        'values' => [1, 2, 3]
      }
    },
      'arrayValue',
      [1, 2, 3]
    ))
  end
  
  def test_attribute_value_matches_expected_type_incorrect
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'stringValue' => 'STRING'
      },
      'intValue',
      12345
    ))
  end

  def test_attribute_value_matches_value_failures
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'stringValue' => 'STRING'
      },
      'stringValue',
      'INCORRECT'
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'intValue' => '123456'
    },
      'intValue',
      654321
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'bytesValue' => 'BYTES'
    },
      'bytesValue',
      'NO_BYTES'
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => 'false'
    },
      'boolValue',
      true
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'boolValue' => 'true'
    },
      'boolValue',
      false
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'doubleValue' => '1.52'
      },
      'doubleValue',
      2.51
    ))
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
      'arrayValue' => {
        'values' => [1, 2, 3]
      }
    },
      'arrayValue',
      [4, 5, 6]
    ))
  end

  def test_attribute_value_matches_invalid_types
    $logger.expects(:error).with('Span attribute validation does not currently support the "kvlistValue" type')
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'kvlistValue' => 'STRING'
      },
      'kvlistValue',
      'INCORRECT'
    ))
    $logger.expects(:error).with("An invalid attribute type was expected: 'nottaType'")
    assert_false(Maze::Accessors::TraceAccessors.attribute_value_matches?({
        'nottaType' => 'STRING'
      },
      'nottaType',
      'INCORRECT'
    ))
  end
end
