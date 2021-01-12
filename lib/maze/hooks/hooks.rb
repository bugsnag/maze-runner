# frozen_string_literal: true

module Maze
  module Hooks
    # Provides the ability for callbacks to be provided as part of running Cucumber.
    # These are akin to Cucumber's AfterConfiguration, Before and After hooks, but are invoked in such a way that
    # Maze Runner's hooks do not interfere with callbacks registered by clients.
    class Hooks
      def initialize
        @after_configuration = []
        @before = []
        @after = []
      end

      # Register blocks to be called from a Cucumber AfterConfiguration hook (after MazeRunner does everything it needs to)
      def after_configuration(&block)
        @after_configuration << block
      end

      # Register blocks to be called from a Cucumber Before hook (after MazeRunner does everything it needs to)
      def before(&block)
        @before << block
      end

      # Register blocks to be called from a Cucumber After hook (before MazeRunner does everything it needs to)
      def after(&block)
        @after << block
      end

      # For MazeRunner use only, call the registered AfterConfiguration blocks
      # @param config Cucumber config
      def call_after_configuration(config)
        @after_configuration.each { |block| block.call(config) }
      end

      # For MazeRunner use only, call the registered Before blocks
      # @param scenario The current Cucumber scenario
      def call_before(scenario)
        @before.each { |block| block.call(scenario) }
      end

      # For MazeRunner use only, call the registered After blocks
      # @param scenario The current Cucumber scenario
      def call_after(scenario)
        @after.each { |block| block.call(scenario) }
      end
    end
  end
end
