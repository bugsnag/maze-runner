require 'test_helper'
require_relative '../lib/maze/error_captor'

class ErrorCaptorTest < Test::Unit::TestCase
  def test_initial_state
    captor = Maze::ErrorCaptor.clone.instance
    assert_false(captor.captured_errors_exist?)
    assert(captor.captured_errors.empty?)
    assert(captor.get_captured_error_classes.empty?)
    assert(captor.get_captured_error_messages.empty?)
  end

  def test_add_and_reset_state
    captor = Maze::ErrorCaptor.clone.instance
    report = mock('report')
    captor.add_captured_error(report)
    assert(captor.captured_errors_exist?)
    assert_false(captor.captured_errors.empty?)
    captor.reset_captured_errors
    assert_false(captor.captured_errors_exist?)
    assert(captor.captured_errors.empty?)
  end

  def test_get_captured_error_details
    captor = Maze::ErrorCaptor.clone.instance
    report = mock('report')
    error_class = 'foo'
    error_message = 'bar'
    report.expects(:summary).times(4).returns({ error_class: error_class, message: error_message })
    captor.add_captured_error(report)
    captor.add_captured_error(report)
    assert(captor.captured_errors_exist?)
    assert_false(captor.captured_errors.empty?)
    assert_equal(captor.captured_errors.size, 2)
    assert_equal([error_class, error_class], captor.get_captured_error_classes)
    assert_equal([error_message, error_message], captor.get_captured_error_messages)
    captor.reset_captured_errors
    assert_false(captor.captured_errors_exist?)
    assert(captor.captured_errors.empty?)
  end
end
