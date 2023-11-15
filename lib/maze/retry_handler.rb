# frozen_string_literal: true

require 'appium_lib'

module Maze
  # Handles the logic of when a test should be retried after a failure.
  # Note: This class expects a failed test. For repeating a single test see RepeatHandler
  class RetryHandler
    class << self

      # Acceptable tags to indicate a test should be restarted
      RETRY_TAGS = %w[@retry @retryable @retriable].freeze

      # Determines whether a failed test_case should be restarted
      #
      # @param test_case [Cucumber::RunningTestCase] The current test_case or scenario
      # @param event [Cucumber::Core::Event] The triggering event
      def should_retry?(test_case, event)
        # Only retry if the option is set and we haven't already retried
        return false if !Maze.config.enable_retries || retried_previously?(test_case)

        if retry_on_driver_error?(event)
          $logger.warn "Retrying #{test_case.name} due to driver error: #{event.result.exception}"
          if Maze.driver.is_a?(Maze::Driver::Appium)
            if Maze.config.farm.eql?(:bb)
              Maze::Hooks::ErrorCodeHook.exit_code = Maze::Api::ExitCode::APPIUM_SESSION_FAILURE
            else
              Maze.driver.restart
            end
          elsif Maze.driver.is_a?(Maze::Driver::Browser)
            Maze.driver.refresh
          end
        elsif retry_on_tag?(test_case)
          $logger.warn "Retrying #{test_case.name} due to retry tag"
        elsif Maze.dynamic_retry
          $logger.warn "Retrying #{test_case.name} due to dynamic retry set"
        else
          return false
        end
        increment_retry_count(test_case)
        true
      end

      def retried_previously?(test_case)
        global_retried[test_case] > 0
      end

      private

      def increment_retry_count(test_case)
        global_retried[test_case] += 1
      end

      def retry_on_driver_error?(event)
        error_class = event.result.exception.class
        maze_errors = Maze::Error::ERROR_CODES
        Maze.driver && maze_errors.include?(error_class) && maze_errors[error_class][:retry]
      end

      def retry_on_tag?(test_case)
        test_case.tags.any? do |tag|
          RETRY_TAGS.include?(tag.name)
        end
      end

      def global_retried
        @global_retried ||= Hash.new { |h, k| h[k] = 0 }
      end
    end
  end
end
