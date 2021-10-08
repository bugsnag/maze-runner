# frozen_string_literal: true

require 'cucumber/core/filter'
require 'cucumber/running_test_case'
require 'cucumber/events'

module Maze
  module Plugins
    class SeleniumRetryPlugin < Cucumber::Core::Filter.new(:configuration)

      SELENIUM_ERRORS = [
        Selenium::WebDriver::Error::UnknownError,
        Selenium::WebDriver::Error::WebDriverError
      ]

      def test_case(test_case)
        configuration.on_event(:test_case_finished) do |event|
          next unless retry_required?

          retried_cases << test_case
          # Restart appium driver
          Maze.driver.restart
          # Re-run test
          test_case.describe_to(receiver)
        end

        super
      end

      private

      def retry_required?(test_case, event)
        event.test_case == test_case &&
          event.result.failed? &&
          !retried_cases.include?(test_case) &&
          is_selenium_error?(event)
      end

      def is_selenium_error?(event)
        SELENIUM_ERRORS.include?(event.result.exception.class)
      end

      def retried_cases
        @retried_cases ||= []
      end
    end
  end
end
