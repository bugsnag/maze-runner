require 'bugsnag'

# Contains logic for running Bugsnag
module Maze
  module Hooks
    class BugsnagHooks
      class << self
        def start_bugsnag
          # Use MAZE_BUGSNAG_API_KEY explicitly to avoid collisions with test env
          return unless ENV['MAZE_BUGSNAG_API_KEY']

          Bugsnag.configure do |config|
            config.api_key = ENV['MAZE_BUGSNAG_API_KEY']
            config.add_metadata(:'test driver', {
              'driver type': Maze.driver.class
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
            config.add_metadata(:'git', {
              'branch': `git rev-parse --abbrev-ref HEAD`,
              'remote': `git config --get remote.origin.url`,
              'commit': `git log -n 1 --no-decorate`
            }) if has_git?
            config.vendor_paths = ['vendor', '.bundle', 'minitest']
          end

          Bugsnag.start_session

          at_exit do
            if $!
              Bugsnag.notify($!)
            end
          end

        end

        private

        def has_git?
          # This is horrible, do something better
          `git`
          `git status`
          $?.success?
          true
        rescue Errno::ENOENT
          false
        end
      end
    end
  end
end
