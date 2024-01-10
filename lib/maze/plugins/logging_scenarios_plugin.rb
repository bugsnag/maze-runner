# frozen_string_literal: true

require 'bugsnag'
require 'cucumber/core/filter'

module Maze
  module Plugins
    class LoggingScenariosPlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_step_started) do |event|
          $logger.trace "Step started: #{event.test_step.to_s}"
        end

        super
      end
    end
  end
end
