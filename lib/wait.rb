# frozen_string_literal: true

module Maze
  # Allows repeated attempts at something, until it is successful or the timeout
  # is exceed
  class Wait
    # @param interval [Numeric] Optional. The time to sleep between attempts
    # @param timeout [Numeric] The amount of time to spend on attempts before giving up
    def initialize(interval: 0.1, timeout:)
      raise "Interval must be greater than zero, got '#{interval}'" unless interval > 0
      raise "Timeout (#{timeout}) must be greater than interval (#{interval})" unless timeout > interval

      @interval = interval
      @max_attempts = timeout / interval
    end

    # Wait until the given block succeeds (returns a truthy value) or the
    # timeout is exceeded
    #
    # @return [Object] The last value returned by the block
    def until(&block)
      success = false
      attempts = 0

      until success || attempts >= @max_attempts do
        attempts += 1
        success = block.call

        sleep @interval unless success
      end

      success
    end
  end
end
