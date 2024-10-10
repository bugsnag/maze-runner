# frozen_string_literal: true

require 'singleton'

module Maze
  class ErrorCaptor
    include Singleton

    attr_reader :captured_errors

    def initialize
      @captured_errors = []
    end

    # Sets the last error report that BugSnag has captured
    #
    # @param report [Bugsnag::Report] The report to set
    def add_captured_error(report)
      @captured_errors << report
    end

    # Returns an array of the primary error classes of captured error reports
    #
    # @return [Array<String>] The error classes
    def get_captured_error_classes
       @captured_errors.map { |report| report.summary[:error_class] }
    end

    # Returns the primary error messages of the captured error reports
    #
    # @return [Array<String>] The error messages
    def get_captured_error_messages
      @captured_errors.map { |report| report.summary[:message] }
    end

    # Resets the captured errors array
    def reset_captured_errors
      @captured_errors = []
    end

    # Whether any error reports exist in the current context
    #
    # @return [Boolean] Whether a report exists
    def captured_errors_exist?
      !@captured_errors.empty?
    end
  end
end
