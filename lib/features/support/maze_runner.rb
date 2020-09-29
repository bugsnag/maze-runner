# frozen_string_literal: true

require_relative './configuration'

# Glues the various parts of MazeRunner together that need to be accessed globally,
# providing an alternative to the proliferation of global variables or singletons.
class MazeRunner
  class << self
    attr_accessor :driver
    def configuration
      @configuration ||= Configuration.new
    end
  end
end
