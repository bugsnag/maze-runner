# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/maze/timers'

class TimerTest < Test::Unit::TestCase
  def test_run_stop

    timer = Maze::Timer.new
    assert_equal 0, timer.total

    # Run/stop 1
    timer.run
    sleep 0.1
    timer.stop
    assert_operator timer.total, :>, 0.099
    assert_operator timer.total, :<, 0.2

    sleep 0.1

    # Run/stop 2
    timer.run
    sleep 0.1
    timer.stop
    assert_operator timer.total, :>, 0.199
    assert_operator timer.total, :<, 0.3

    # Reset
    timer.reset
    assert_equal 0, timer.total
  end
end
