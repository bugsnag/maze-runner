# frozen_string_literal: true

module Maze
  module Hooks
    # Hooks for Browser mode use
    class LoggerHooks
      class << self
        def before(scenario)
          location = "\"# #{scenario.location}\""
          $logger.trace ''
          $logger.trace "\n--- Begin Scenario: #{scenario.name} #{location}"
        end

        def after(scenario)
          location = "\"# #{scenario.location}\""
          $logger.trace "--- End Scenario: #{scenario.name} #{location}"
          $logger.trace ''
        end

        def after_all
          if ENV['BUILDKITE']
            FileUtils.mv("#{Dir.pwd}/#{Maze::Loggers::FileLogger::LOG_LOCATION}", "#{Dir.pwd}/maze_output/maze-runner.log")
          end
        end
      end
    end
  end
end
