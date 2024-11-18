# frozen_string_literal: true

module Maze
  class ErrorCaptor
    attr_reader :captured_errors

    class << self

      # Sets the last error report that BugSnag has captured
      #
      # @param report [Bugsnag::Report] The report to set
      def add(report)
        captured_errors << report
      end

      # Returns an array of the primary error classes of captured error reports
      #
      # @return [Array<String>] The error classes
      def classes
        captured_errors.map { |report| report.summary[:error_class] }
      end

      # Returns the primary error messages of the captured error reports
      #
      # @return [Array<String>] The error messages
      def messages
        captured_errors.map { |report| report.summary[:message] }
      end

      # Resets the captured errors array
      def reset
        @captured_errors = []
      end

      # Whether any error reports exist in the current context
      #
      # @return [Boolean] Whether a report exists
      def empty?
        captured_errors.empty?
      end

      def captured_errors
        @captured_errors ||= []
      end
    end
  end
end
