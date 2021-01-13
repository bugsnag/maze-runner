# frozen_string_literal: true

require 'logger'
require 'singleton'

# Logger classes
module Maze
  # A logger, with level configured according to the environment
  class Logger < Logger
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
          log_hash_by_field severity, data
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
        "\033]1339;url='#{url}';content='#{text}'\a"
      end
    end
  end
end
