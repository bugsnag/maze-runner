# frozen_string_literal: true

require_relative 'maze/configuration'
require_relative 'maze/hooks/hooks'

# Glues the various parts of MazeRunner together that need to be accessed globally,
# providing an alternative to the proliferation of global variables or singletons.
module Maze
  VERSION = '5.9.1'

  class << self
    attr_accessor :driver
    attr_accessor :internal_hooks
    attr_accessor :mode
    attr_accessor :start_time
    def config
      @config ||= Maze::Configuration.new
    end

    def hooks
      @hooks ||= Maze::Hooks::Hooks.new
    end
  end
end
