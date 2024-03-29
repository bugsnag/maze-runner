# frozen_string_literal: true

require 'logger'

module Maze
  module Loggers
    # A logger to file, always logging at TRACE level
    class FileLogger < Logger

      LOG_LOCATION = 'maze-runner.log'

      include Singleton

      attr_accessor :datetime_format

      def initialize
        # Remove the previous log file if it exists
        File.delete(LOG_LOCATION) if File.exist?(LOG_LOCATION)

        super(LOG_LOCATION, level: ::Logger::TRACE)

        @datetime_format = '%H:%M:%S'

        @formatter = proc do |severity, time, _name, message|
          formatted_time = time.strftime(@datetime_format)

          "\e[2m[#{formatted_time}]\e[0m #{severity.rjust(5)}: #{message}\n"
        end
      end
    end
  end
end
