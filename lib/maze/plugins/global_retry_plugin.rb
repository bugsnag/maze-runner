# frozen_string_literal: true

require 'cucumber/core/filter'

module Maze
  module Plugins
    class GlobalRetryPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|

          # Ensure we're in the correct test case
          next unless event.test_case == test_case

          # Set retry to 0
          set_retry_count(configuration, 0)

          # Guard to check if the case should be retried
          should_retry = event.result.failed? && Maze::RetryHandler.should_retry?(test_case, event)

          next unless should_retry

          # Set retry to 1
          set_retry_count(configuration, 1)
        end

        super
      end

      def set_retry_count(configuration, count)
        pp "Retry to #{count}"
        opts = configuration.instance_variable_get(:@options)
        opts[:retry] = count
        configuration.instance_variable_set(:@options, opts)
      end
    end
  end
end
