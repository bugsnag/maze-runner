require 'bugsnag'

# Contains logic for running Bugsnag
module Maze
  module ErrorMonitor
      # This class is responsible for configuring Bugsnag
      # and setting up the middleware for error reporting.
      #
      # @api private
      #
      # @see https://docs.bugsnag.com/platforms/ruby/rails/
      # @see https://docs.bugsnag.com/platforms/ruby/rails/middleware/
    class Config
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
            config.middleware.use(SeleniumErrorMiddleware)
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
    end
  end
end
