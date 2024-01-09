# frozen_string_literal: true

require 'logger'

module Maze
  # A logger to STDOUT, with level configured according to the environment
  class STDOUTLogger < Logger
    include Singleton

    attr_accessor :datetime_format

    def initialize
      if ENV['TRACE']
        super(STDOUT, level: ::Logger::TRACE)
      elsif ENV['DEBUG']
        super(STDOUT, level: ::Logger::DEBUG)
      elsif ENV['QUIET']
        super(STDOUT, level: ::Logger::ERROR)
      else
        super(STDOUT, level: ::Logger::INFO)
      end

      @datetime_format = '%H:%M:%S'

      @formatter = proc do |severity, time, _name, message|
        formatted_time = time.strftime(@datetime_format)

        "\e[2m[#{formatted_time}]\e[0m #{severity.rjust(5)}: #{message}\n"
      end
    end
  end
end
