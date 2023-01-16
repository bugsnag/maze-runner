require 'json'

module Maze
  module Internal
    # Handles the Maze Runner configuration file for test fixtures
    class FixtureConfig
      DEVICE_FILENAME = 'fixture_config.json'
      WORKING_FILE = File.join('maze_working', DEVICE_FILENAME)

      def initialize
        @config = {}
      end

      def add(key, value)
        @config[key] = value
      end

      def write
        File.open(WORKING_FILE, 'w+') do |file|
          file.write(JSON.pretty_generate(@config))
        end
      end
    end
  end
end
