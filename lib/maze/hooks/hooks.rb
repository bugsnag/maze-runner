# frozen_string_literal: true

module Maze
  module Hooks
    # Provides the ability for callbacks to be provided as part of running Cucumber.
    # These are akin to Cucumber's BeforeAll, Before, After and AfterAll hooks, but are invoked in such a way that
    # Maze Runner's hooks do not interfere with callbacks registered by clients.
    class Hooks
      def initialize
        @before_all = []
        @before = []
        @pre_complete = []
        @after = []
      end

      # Register blocks to be called from a Cucumber BeforeAll hook (after MazeRunner does everything it needs to)
      def before_all(&block)
        @before_all << block
      end

      # Register blocks to be called from a Cucumber Before hook (after MazeRunner does everything it needs to)
      def before(&block)
        @before << block
      end

      # Register blocks to be called from a Cucumber After hook (before the scenario is completed)
      def pre_complete(&block)
        @pre_complete << block
      end

      # Register blocks to be called from a Cucumber After hook (after the scenario is completed but before MazeRunner
      # does everything it needs to between scenarios)
      def after(&block)
        @after << block
      end

      # For MazeRunner use only, call the registered BeforeAll blocks
      def call_before_all
        @before_all.each(&:call)
      end

      # For MazeRunner use only, call the registered Before blocks
      # @param scenario The current Cucumber scenario
      def call_before(scenario)
        @before.each { |block| block.call(scenario) }
      end

      # For MazeRunner use only, call the registered pre-complete blocks
      # @param scenario The current Cucumber scenario
      def call_pre_complete(scenario)
        @pre_complete.each { |block| block.call(scenario) }
      end

      # For MazeRunner use only, call the registered After blocks
      # @param scenario The current Cucumber scenario
      def call_after(scenario)
        @after.each { |block| block.call(scenario) }
      end
    end

    # Base class for hooks internal to Maze Runner
    class InternalHooks
      def before_all; end

      def before(_scenario); end
      def pre_complete(_scenario); end
      def after(_scenario); end

      def after_all; end

      def at_exit; end
    end
  end
end
