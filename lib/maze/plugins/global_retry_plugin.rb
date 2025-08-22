# frozen_string_literal: true

require 'cucumber/core/filter'

# Required to access the options
module Cucumber
  class Configuration
    attr_accessor :options
  end
end

module Maze
  module Plugins
    class GlobalRetryPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|

          # Ensure we're in the correct test case
          next unless event.test_case == test_case

          # Set retry to 0
          configuration.options[:retry] = 0

          # Guard to check if the case should be retried
          should_retry = event.result.failed? && Maze::RetryHandler.should_retry?(test_case)

          next unless should_retry

          # Set retry to 1
          configuration.options[:retry] = 1
        end

        super
      end
    end
  end
end
