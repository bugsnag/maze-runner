# frozen_string_literal: true

require 'cucumber/core/filter'

module Maze
  module Plugins
    class GlobalRetryPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|
          # Guard for the test_case having failed
          next unless event.test_case == test_case && event.result.failed?

          # Guard to check if the case should be retried
          next unless Maze::RetryHandler.should_retry?(test_case, event)

          # Retry the test_case
          test_case.describe_to(receiver)
        end

        super
      end
    end
  end
end
