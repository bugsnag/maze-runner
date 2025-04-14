# frozen_string_literal: true

require_relative 'maze/configuration'
require_relative 'maze/hooks/hooks'
require_relative 'maze/timers'

# Glues the various parts of MazeRunner together that need to be accessed globally,
# providing an alternative to the proliferation of global variables or singletons.
module Maze

  VERSION = '9.28.0'

  class << self
    attr_accessor :check, :driver, :internal_hooks, :mode, :start_time, :dynamic_retry, :public_address,
                  :public_document_server_address, :run_uuid, :scenario

    def config
      @config ||= Maze::Configuration.new
    end

    def hooks
      @hooks ||= Maze::Hooks::Hooks.new
    end

    def timers
      @timers ||= Maze::Timers.new
    end
  end
end
