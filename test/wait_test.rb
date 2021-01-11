# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/maze/wait'

# noinspection RubyNilAnalysis
class WaitTest < Test::Unit::TestCase
  def test_it_returns_block_result_on_success
    wait = Maze::Wait.new(timeout: 1)

    result = wait.until { true }

    assert_true(result)
  end

  def test_it_retries_until_block_returns_truthy_value
    wait = Maze::Wait.new(interval: 0.01, timeout: 0.1)

    attempts = 0

    result = wait.until(&lambda do
      attempts += 1

      return false if attempts < 5

      true
    end)

    assert_true(result)
    assert_equal(attempts, 5)
  end

  def test_it_retries_until_it_times_out
    wait = Maze::Wait.new(interval: 0.01, timeout: 0.1)

    attempts = 0

    result = wait.until(&lambda do
      attempts += 1

      return false if attempts < 500

      # this will never be reached as the timeout is shorter than the time it
      # would take to reach 500 attempts
      true
    end)

    assert_false(result)
    assert_equal(attempts, 10)
  end

  def test_it_raises_when_timeout_is_zero
    assert_raises(RuntimeError, "Timeout must be greater than zero, got '0'") do
      Maze::Wait.new(timeout: 0)
    end
  end

  def test_it_raises_when_interval_is_zero
    assert_raises(RuntimeError, 'Interval (0) must be greater than timeout (1)') do
      Maze::Wait.new(interval: 0, timeout: 1)
    end
  end

  def test_it_raises_when_timeout_is_negative
    assert_raises(RuntimeError, "Timeout must be greater than zero, got '-1'") do
      Maze::Wait.new(timeout: -1)
    end
  end

  def test_it_raises_when_interval_is_negative
    assert_raises(RuntimeError, 'Interval (-5) must be greater than timeout (1)') do
      Maze::Wait.new(interval: -5, timeout: 1)
    end
  end
end
