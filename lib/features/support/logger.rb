# frozen_string_literal: true

require 'logger'

# A logger, with level configured according to the environment
class MazeLogger < Logger
  include Singleton
  def initialize
    if ENV['VERBOSE'] || ENV['DEBUG']
      super(STDOUT, level: Logger::DEBUG)
    elsif ENV['QUIET']
      super(STDOUT, level: Logger::ERROR)
    else
      super(STDOUT, level: Logger::INFO)
    end
    self.datetime_format = '%Y-%m-%d %H:%M:%S'
  end
end

$logger = MazeLogger.instance
