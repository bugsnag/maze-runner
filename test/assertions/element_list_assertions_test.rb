# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/helper'
require_relative '../../lib/maze/assertions/element_list_assertions'

class ElementListAssertionsTest < Test::Unit::TestCase

  def test_equals_successes
    request = {
      'equals' => {
        'true' => true,
        'false' => false,
        'string' => 'string',
        'number' => 12345,
      }
    }
    expectations = [
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.true',
        value: true
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.false',
        value: false
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.string',
        value: 'string'
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.number',
        value: 12345
      }
    ]
    Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
  end

  def test_regex_success
    request = {
      'regex' => 'abc123'
    }
    expectations = [
      {
        type: Maze::Assertions::REGEX,
        element: 'regex',
        value: '[abc123]{6}'
      }
    ]
    Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
  end

  def test_exists_success
    request = {
      'exists' => 'foobar'
    }
    expectations = [
      {
        type: Maze::Assertions::EXISTS,
        element: 'exists'
      }
    ]
    Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
  end

  def test_compares_success
    request = {
      'small' => 1,
      'big' => 5,
      'unit' => 1,
    }
    expectations = [
      {
        type: Maze::Assertions::COMPARE,
        element: 'big',
        comparison: Maze::Assertions::GREATER,
        value: 'small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'small',
        comparison: Maze::Assertions::LESSER,
        value: 'big'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'unit',
        comparison: Maze::Assertions::EQUAL,
        value: 'small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'big',
        comparison: Maze::Assertions::NOT_EQUAL,
        value: 'unit'
      }
    ]
    Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
  end

  def test_combined_successes
    request = {
      'equals' => {
        'true' => true,
        'false' => false,
        'string' => 'string',
        'number' => 12345,
      },
      'regex' => {
        'val' => 'abc123'
      },
      'exists' => {
        'foo' => 'bar'
      },
      'compare' => {
        'small' => 1,
        'big' => 5,
        'unit' => 1,
      }
    }
    expectations = [
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.true',
        value: true
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.false',
        value: false
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.string',
        value: 'string'
      },
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.number',
        value: 12345
      },
      {
        type: Maze::Assertions::REGEX,
        element: 'regex.val',
        value: '[abc123]{6}'
      },
      {
        type: Maze::Assertions::EXISTS,
        element: 'exists.foo'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'compare.big',
        comparison: Maze::Assertions::GREATER,
        value: 'compare.small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'compare.small',
        comparison: Maze::Assertions::LESSER,
        value: 'compare.big'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'compare.unit',
        comparison: Maze::Assertions::EQUAL,
        value: 'compare.small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'compare.big',
        comparison: Maze::Assertions::NOT_EQUAL,
        value: 'compare.unit'
      }
    ]
    Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
  end

  def test_equals_failure
    request = {
      'equals' => {
        'true' => true
      }
    }
    expectations = [
      {
        type: Maze::Assertions::EQUALS,
        element: 'equals.true',
        value: false
      }
    ]
    assert_raise(RuntimeError, 'Element equals.true was expected to be false, but was true') do
      Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
    end
  end

  def test_regex_failure
    request = {
      'regex' => {
        'value' => 'abc123'
      }
    }
    expectations = [
      {
        type: Maze::Assertions::REGEX,
        element: 'regex.value',
        value: '[ab12]{6}'
      }
    ]
    assert_raise(RuntimeError, 'Element regex.value was expected to match the regex [ab12]{6}, but was abc123') do
      Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
    end
  end

  def test_exists_failure
    request = {
      'exists' => {}
    }
    expectations = [
      {
        type: Maze::Assertions::EXISTS,
        element: 'exists.here'
      }
    ]
    assert_raise(RuntimeError, 'Element exists.here was expected to be non-null') do
      Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
    end
  end

  def test_compares_failure
    request = {
      'small' => 1,
      'big' => 5,
      'unit' => 1,
    }
    expectations = [
      {
        type: Maze::Assertions::COMPARE,
        element: 'big',
        comparison: Maze::Assertions::LESSER,
        value: 'small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'small',
        comparison: Maze::Assertions::GREATER,
        value: 'big'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'unit',
        comparison: Maze::Assertions::NOT_EQUAL,
        value: 'small'
      },
      {
        type: Maze::Assertions::COMPARE,
        element: 'big',
        comparison: Maze::Assertions::EQUAL,
        value: 'unit'
      }
    ]
    assert_raise(RuntimeError, %{
      Element big, 5 was expected to be lesser compared to small, 1
      Element small, 1 was expected to be greater compared to big, 5
      Element unit, 1 was expected to be not_equal compared to small, 1
      Element big, 5 was expected to be equal compared to unit, 1
    }) do
      Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
    end
  end

  def test_invalid_regex_assertion
    request = {
      'regex' => {
        'value' => 'abc123'
      }
    }
    expectations = [
      {
        type: Maze::Assertions::REGEX,
        element: 'regex.value'
      }
    ]
    assert_raise(RuntimeError, 'Regex comparison for element regex.value must have a valid regex') do
      Maze::Assertions::ElementListAssertions.assert_elements_match(request, expectations)
    end
  end
end
