require 'bugsnag'

# Contains logic for running Bugsnag
module Maze
  class BugsnagConfig
    class << self
      def start_bugsnag(cucumber_config)
        # Use MAZE_BUGSNAG_API_KEY explicitly to avoid collisions with test env
        return unless ENV['MAZE_BUGSNAG_API_KEY']

        Bugsnag.configure do |config|
          config.api_key = ENV['MAZE_BUGSNAG_API_KEY']
          config.add_metadata(:'test driver', {
            'driver type': Maze.driver.class,
            'device farm': Maze.config.farm,
            'capabilities': Maze.config.capabilities
          }) if Maze.driver
          config.add_metadata(:'buildkite', {
            'pipeline': ENV['BUILDKITE_PIPELINE_NAME'],
            'repo': ENV['BUILDKITE_REPO'],
            'build url': ENV['BUILDKITE_BUILD_URL'],
            'branch': ENV['BUILDKITE_BRANCH'],
            'builder': ENV['BUILDKITE_BUILD_CREATOR'],
            'message': ENV['BUILDKITE_MESSAGE'],
            'step': ENV['BUILDKITE_LABEL']
          }) if ENV['BUILDKITE']
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
