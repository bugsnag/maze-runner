require 'bugsnag'

# Contains logic for running Bugsnag
module Maze
  class BugsnagConfig
    class << self
      def start_bugsnag(cucumber_config)
        # Use MAZE_BUGSNAG_API_KEY explicitly to avoid collisions with test env
        return unless Maze.config.enable_bugsnag && ENV['MAZE_BUGSNAG_API_KEY']

        Bugsnag.configure do |config|
          config.api_key = ENV['MAZE_BUGSNAG_API_KEY']
          config.app_version = Maze::VERSION
          config.add_metadata(:'test driver', {
            'driver type': Maze.driver.class,
            'device farm': Maze.config.farm,
            'capabilities': Maze.config.capabilities
          }) if Maze.driver

          if ENV['BUILDKITE']
            metadata = {
              'pipeline': ENV['BUILDKITE_PIPELINE_NAME'],
              'repo': ENV['BUILDKITE_REPO'],
              'build url': ENV['BUILDKITE_BUILD_URL'],
              'branch': ENV['BUILDKITE_BRANCH'],
              'builder': ENV['BUILDKITE_BUILD_CREATOR'],
              'message': ENV['BUILDKITE_MESSAGE'],
              'step': ENV['BUILDKITE_LABEL']
            }
            if ENV['BUILDKITE_JOB_ID']
              metadata['job url'] = ENV['BUILDKITE_BUILD_URL'] + "#" + ENV['BUILDKITE_JOB_ID']
            end
          end
          config.middleware.use(AssertErrorMiddleware)
          config.middleware.use(AmbiguousErrorMiddleware)
          config.add_metadata(:'buildkite', metadata)
          config.project_root = Dir.pwd
        end

        Bugsnag.start_session

        at_exit do
          if $!
            Bugsnag.notify($!)
          end
        end
      end
    end

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
      AMBIGUOUS_ERROR_CLASSES = [
        'Selenium::WebDriver::Error::ServerError',
        'Selenium::WebDriver::Error::UnknownError'
      ]

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

    class ErrorCaptureMiddleware

      def initialize(middleware)
        @middleware = middleware
      end

      def call(report)
        Maze::ErrorCaptor.instance.add_captured_error(report.dup)

        @middleware.call(report)
      end
    end
  end
end
