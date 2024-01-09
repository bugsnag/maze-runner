# frozen_string_literal: true

require 'logger'

module Maze
  # A logger to file, always logging at TRACE level
  class FileLogger < Logger
    include Singleton

    attr_accessor :datetime_format

    def initialize
      super('maze.log', level: ::Logger::TRACE)

      @datetime_format = '%H:%M:%S'

      @formatter = proc do |severity, time, _name, message|
        formatted_time = time.strftime(@datetime_format)

        "\e[2m[#{formatted_time}]\e[0m #{severity.rjust(5)}: #{message}\n"
      end
    end
  end
end