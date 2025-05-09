module Maze
  module ErrorMonitor
    class AssertErrorMiddleware
      IGNORE_CLASS_NAME = 'Test::Unit::AssertionFailedError'

      # @param middleware [#call] The next middleware to call
      def initialize(middleware)
        @middleware = middleware
      end

      def call(report)
        # Only ignore automated notifies with assertion errors
        automated = report.unhandled

        class_match = report.raw_exceptions.any? do |ex|
          ex.class.name.eql?(IGNORE_CLASS_NAME)
        end

        report.ignore! if automated && class_match

        @middleware.call(report)
      end
    end

    class AmbiguousErrorMiddleware
      AMBIGUOUS_ERROR_CLASSES = %w[Selenium::WebDriver::Error::ServerError Selenium::WebDriver::Error::UnknownError]

      def initialize(middleware)
        @middleware = middleware
      end

      def call(report)
        first_ex = report.raw_exceptions.first
        if AMBIGUOUS_ERROR_CLASSES.include?(first_ex.class.name)
          report.grouping_hash = first_ex.class.name.to_s + first_ex.message.to_s
        end

        @middleware.call(report)
      end
    end
  end
end