# frozen_string_literal: true

require_relative './configuration'
require_relative '../hooks/client_hooks'

# Glues the various parts of MazeRunner together that need to be accessed globally,
# providing an alternative to the proliferation of global variables or singletons.
class MazeRunner
  class << self
    attr_accessor :driver
    def config
      @config ||= Maze::Configuration.new
    end

    def hooks
      @hooks ||= Hooks.new
    end
  end
end
