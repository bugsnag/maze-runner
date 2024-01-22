# frozen_string_literal: true

require 'bugsnag'
require 'logger'
require 'singleton'
require_relative 'file_logger'
require_relative 'log_util'
require_relative 'stdout_logger'

# Monkey patch a 'trace' log level into the standard Logger
class Logger
  remove_const(:SEV_LABEL)
  SEV_LABEL = {
    -1 => 'TRACE',
    0 => 'DEBUG',
    1 => 'INFO',
    2 => 'WARN',
    3 => 'ERROR',
    4 => 'FATAL',
    5 => 'ANY'
  }
  
  module Severity
    TRACE=-1
  end
  
  def trace(name = nil, &block)
    add(TRACE, nil, name, &block)
  end
  
  def trace?
    @level <= TRACE
  end
end

module Maze
  module Loggers
    class Logger
      include Singleton

      attr_accessor :stdout_logger, :file_logger

      def initialize
        @stdout_logger = Maze::Loggers::STDOUTLogger.instance
        @file_logger = Maze::Loggers::FileLogger.instance
      end

      # Attempts to forward all method calls to both loggers
      def method_missing(method, *args, &block)
        if @stdout_logger.respond_to?(method) && @file_logger.respond_to?(method)
          @stdout_logger.send(method, *args, &block)
          @file_logger.send(method, *args, &block)
        else
          super
        end
      end
    end
  end
end

$logger = Maze::Loggers::Logger.instance
