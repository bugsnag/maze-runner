# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../../lib/maze/timers'

class TimerTest < Test::Unit::TestCase
  def test_time

    timer = Maze::Timer.new
    assert_equal 0, timer.total

    # Time 1
    timer.time do
      sleep 0.1
    end
    assert_operator timer.total, :>, 0.099
    assert_operator timer.total, :<, 0.2

    sleep 0.1

    # Time 2
    timer.time do
      sleep 0.1
    end
    assert_operator timer.total, :>, 0.199
    assert_operator timer.total, :<, 0.3

    # Reset
    timer.reset
    assert_equal 0, timer.total
  end
end
