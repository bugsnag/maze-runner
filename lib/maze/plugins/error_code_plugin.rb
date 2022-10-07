# frozen_string_literal: true

module Maze
  module Plugins
    class ErrorCodePlugin < Cucumber::Core::Filter.new(:configuration)

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|

          # Ensure we're in the correct test case, and the test failed
          next unless event.test_case == test_case
          next unless event.result.failed?

          Maze::Hooks::ErrorCodeHook.add_test_error(event.result.exception.class)
        end

        super
      end
    end
  end
end
