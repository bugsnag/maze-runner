# frozen_string_literal: true

require 'singleton'

# Singleton class for collecting details about a test run as it progresses. At the end of a test run,
# a summary can be logged.  The initial implementation of this class is very crude, but it can evolve.
class MazeReport
  include Singleton

  def initialize
    @build_id = ''
    @warnings = []
  end

  def add_warning(message)
    @warnings.append message
  end

  def print_report
    STDOUT.puts '+++ MazeRunner Test Run Summary +++'

    if @warnings
      $logger.info 'Warnings logged:'
      @warnings.each { |w| $logger.warn w }
    else
      $logger.info 'No warnings logged'
    end
  end
end
