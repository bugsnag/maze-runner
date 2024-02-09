# frozen_string_literal: true

require 'bugsnag'
require 'cucumber/core/filter'

# Required to access the options
module Cucumber
  class Configuration
    attr_accessor :options
  end
end

module Maze
  module Plugins
    class BugsnagReportingPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_step_finished) do |event|
          @last_test_step = event.test_step if event.result.failed?
        end

        configuration.on_event(:test_case_finished) do |event|

          # Ensure we're in the correct test case and that it's failed
          next unless event.test_case.eql?(test_case) && event.result.failed?

          Bugsnag.notify(event.result.exception) do |bsg_event|

            bsg_event.api_key = ENV['MAZE_SCENARIO_BUGSNAG_API_KEY']

            unless @last_test_step.nil?

              repo = ENV['BUILDKITE_PIPELINE_SLUG']
              bsg_event.context = if repo.nil?
                                    @last_test_step.location
                                  else
                                    "#{repo}/#{@last_test_step.location}"
                                  end
              bsg_event.grouping_hash = @last_test_step.location

              bsg_event.add_metadata(:'scenario', {
                'failing step': @last_test_step.to_s,
                'failing step location': @last_test_step.location
              })
            end
            bsg_event.add_metadata(:'scenario', {
              'scenario name': test_case.name,
              'scenario location': test_case.location,
              'scenario tags': test_case.tags,
              'scenario duration (mS)': event.result.duration.nanoseconds/1000000
            })
          end
        end

        super
      end
    end
  end
end
