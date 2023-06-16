# frozen_string_literal: true

require 'logger'
require 'singleton'

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

# Logger classes
module Maze
  # A logger, with level configured according to the environment
  class Logger < Logger
    include Singleton

    attr_accessor :datetime_format

    def initialize
      if ENV['TRACE']
        super(STDOUT, level: Logger::TRACE)
      elsif ENV['DEBUG']
        super(STDOUT, level: Logger::DEBUG)
      elsif ENV['QUIET']
        super(STDOUT, level: Logger::ERROR)
      else
        super(STDOUT, level: Logger::INFO)
      end

      @datetime_format = '%H:%M:%S'

      @formatter = proc do |severity, time, _name, message|
        formatted_time = time.strftime(@datetime_format)

        "\e[2m[#{formatted_time}]\e[0m #{severity.rjust(5)}: #{message}\n"
      end
    end
  end

  $logger = Maze::Logger.instance

  # A collection of logging utilities
  class LogUtil
    class << self
      # Logs Hash-based data, accounting for things like file upload requests that are too big to log meaningfully.
      #
      # @param severity [Integer] A constant from Logger::Severity
      # @param data [Hash] The data to log (currently needs to be a Hash)
      def log_hash(severity, data)
        return unless data.is_a? Hash

        # Try to pretty print as JSON, if not too big
        begin
          json = JSON.pretty_generate data
          if json.length < 128 * 1024
            $logger.add severity, json
          else
            log_hash_by_field severity, data
          end
        rescue Encoding::UndefinedConversionError
          # Just give up, we don't want to risk a further error trying to log garbage
          $logger.error 'Unable to log hash as JSON'
        end
      end

      # Logs a hash field by field,
      #
      # @param severity [Integer] A Logger::Severity
      # @param hash [Hash] The Hash
      def log_hash_by_field(severity, hash)
        hash.keys.each do |key|
          value = hash[key].to_s
          if value.length < 1024
            $logger.add severity, "  #{key}: #{value}"
          else
            $logger.add severity, "  #{key} (length): #{value.length}"
            $logger.add severity, "  #{key} (start): #{value[0, 1024]}"
          end
        end
      end

      # Produces a clickable link when logged in Buildkite
      # @param url [String] Link URL
      # @param text [String] Link text
      def linkify(url, text)
        if ENV['BUILDKITE']
          "\033]1339;url='#{url}';content='#{text}'\a"
        else
          "#{text}: #{url}"
        end
      end
    end
  end
end
