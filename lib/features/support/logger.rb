# frozen_string_literal: true

require 'logger'

# A logger, with level configured according to the environment
class MazeLogger

  class << self

    def debug(*args)
      logger.debug args
    end

    def info(*args)
      logger.info args
    end

    def warn(*args)
      logger.warn args
    end

    def error(*args)
      logger.error args
    end

    def fatal(*args)
      logger.fatal args
    end

    private

    def logger
      return @logger if @logger

      @logger = if ENV['VERBOSE'] || ENV['DEBUG']
                  Logger.new(STDOUT, level: Logger::DEBUG)
                elsif ENV['QUIET']
                  Logger.new(STDOUT, level: Logger::ERROR)
                else
                  Logger.new(STDOUT, level: Logger::INFO)
                end
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
      @logger
    end
  end
end
