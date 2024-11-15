require 'test_helper'
require_relative '../lib/maze/error_captor'

class ErrorCaptorTest < Test::Unit::TestCase
  def test_initial_state
    captor = Maze::ErrorCaptor.clone
    assert(captor.empty?)
    assert(captor.captured_errors.empty?)
    assert(captor.classes.empty?)
    assert(captor.messages.empty?)
  end

  def test_add_and_reset_state
    captor = Maze::ErrorCaptor.clone
    report = mock('report')
    captor.add(report)
    assert_false(captor.empty?)
    assert_false(captor.captured_errors.empty?)
    captor.reset
    assert(captor.empty?)
    assert(captor.captured_errors.empty?)
  end

  def test_get_captured_error_details
    captor = Maze::ErrorCaptor.clone
    report = mock('report')
    error_class = 'foo'
    error_message = 'bar'
    report.expects(:summary).times(4).returns({ error_class: error_class, message: error_message })
    captor.add(report)
    captor.add(report)
    assert_false(captor.empty?)
    assert_false(captor.captured_errors.empty?)
    assert_equal(captor.captured_errors.size, 2)
    assert_equal([error_class, error_class], captor.classes)
    assert_equal([error_message, error_message], captor.messages)
    captor.reset
    assert(captor.empty?)
    assert(captor.captured_errors.empty?)
  end
end
