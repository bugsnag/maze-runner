require 'json'

module Maze
  module Internal
    # Handles the Maze Runner configuration file for test fixtures
    class FixtureConfig
      DEVICE_FILENAME = 'fixture_config.json'

      def initialize
        @config = {}
      end

      def add(key, value)
        @config[key] = value
      end

      def to_s
        JSON.pretty_generate(@config)
      end
    end
  end
end
