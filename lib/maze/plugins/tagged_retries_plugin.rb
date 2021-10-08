# frozen_string_literal: true

require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events'

module Maze
  module Plugins
    class TaggedRetriesPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|
          next unless retry_required?

          retried_cases << test_case
          test_case.describe_to(receiver)
        end

        super
      end

      private

      def retry_required?(test_case, event)
        event.test_case == test_case &&
          event.result.failed? &&
          !retried_cases.include?(test_case) &&
          has_retryable_tag?(test_case)
      end

      def has_retryable_tag?(test_case)
        test_case.tags.any do |tag|
          tag.name.eql?('@retryable')
        end
      end

      def retried_cases
        @retried_cases ||= []
      end
    end
  end
end
