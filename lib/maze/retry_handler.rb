# frozen_string_literal: true

module Maze
  class RetryHandler
    class << self

      SELENIUM_ERRORS = [
        Selenium::WebDriver::Error::UnknownError,
        Selenium::WebDriver::Error::WebDriverError
      ]

      RETRY_TAGS = [
        '@retry',
        '@retryable',
        '@retriable'
      ]

      def should_retry?(test_case, event)
        return false unless not_retried_previously?(test_case)

        if retry_on_selenium_error(event)
          $logger.warn "Retrying #{test_case.name} due to selenium error: #{event.result.exception}"
          Maze.driver.restart
          increment_retry_count(test_case)
          true
        elsif retry_on_tag?(test_case)
          $logger.warn "Retrying #{test_case.name} due to retry tag"
          increment_retry_count(test_case)
          true
        else
          false
        end
      end

      private

      def increment_retry_count(test_case)
        global_retried[test_case] += 1
      end

      def retry_on_selenium_error(event)
        Maze.driver && SELENIUM_ERRORS.include?(event.result.exception.class)
      end

      def retry_on_tag?(test_case)
        test_case.tags.any do |tag|
          RETRY_TAGS.include?(tag.name)
        end
      end

      def not_retried_previously?(test_case)
        global_retried[test_case] === 0
      end

      def global_retried
        @global_retried ||= Hash.new { |h, k| h[k] = 0 }
      end
    end
  end
end