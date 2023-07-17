module Maze
  module Api
    module Cucumber
      # An abstraction for the underlying Cucumber scenarios
      class Scenario

        # @param scenario The underlying Cucumber scenario
        def initialize(scenario)
          @scenario = scenario
          @fail_override = false
          @fail_override_reason = nil
        end

        def mark_as_failed(reason)
          @fail_override = true
          @fail_override_reason = reason
        end

        def complete
          $logger.info 'Completing scenario'
          @scenario.fail(@fail_override_reason) if @fail_override
        end
      end
    end
  end
end
