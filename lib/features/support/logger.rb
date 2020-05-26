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

# TODO: Added for backward compatibility, but use of the global should be
#   replaced with accessing the singleton instance (assigning to local
#   variables for brevity as appropriate).
$logger = MazeLogger.instance
