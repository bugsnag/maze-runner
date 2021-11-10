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
            config.endpoints = Bugsnag::EndpointConfiguration.new(
              'http://localhost:62000', # Your notify, "Event Server", endpoint
              'http://localhost:62000/sessions', # Your session, "Session Server", endpoint
            )
            config.api_key = ENV['MAZE_BUGSNAG_API_KEY']
            config.add_metadata(:'test driver', {
              'farm': Maze.config.farm,
              'driver type': Maze.driver.class,
              'capabilities': Maze.config.capabilities
            }) unless Maze.driver.nil?
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
          `git status`
          true
        rescue Errno::ENOENT
          false
        end
      end
    end
  end
end
