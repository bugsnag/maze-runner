# frozen_string_literal: true

require 'appium_lib'

module Maze
  # Handles the logic of when a test should be retried after a failure.
  # Note: This class expects a failed test. For repeating a single test see RepeatHandler
  class RetryHandler
    class << self

      # Errors which indicate a selenium/appium driver has crashed and needs to be restarted
      DRIVER_ERRORS = [
        Maze::Error::AppiumElementNotFoundError,

        Selenium::WebDriver::Error::NoSuchElementError,
        Selenium::WebDriver::Error::StaleElementReferenceError,
        Selenium::WebDriver::Error::TimeoutError,
        Selenium::WebDriver::Error::UnknownError,
        Selenium::WebDriver::Error::WebDriverError
      ].freeze

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
          if Maze.driver.is_a?(Maze::Driver::Appium) || Maze.driver.is_a?(Maze::Driver::ResilientAppium)
            Maze.driver.restart
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
        Maze.driver && DRIVER_ERRORS.include?(event.result.exception.class)
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
