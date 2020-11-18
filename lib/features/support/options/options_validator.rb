# frozen_string_literal: true

require_relative 'option'

module Maze
  # Validates command line options
  class OptionValidator
    # Validates all provided options
    # @param options [Hash] Parsed command line options
    def validate(options)
      @errors = []
      @options = options

      # Common options
      farm = options[Option::FARM]
      @errors << "--#{Maze::Option::FARM} must be either 'bs' or 'local' if provided" if farm && !%w[bs local].include?(farm)

      # Farm specific options
      validate_bs if farm == 'bs'
      validate_local if farm == 'local'

      @errors
    end

    # Validates BrowserStack options
    def validate_bs
      @errors << "--#{Maze::Option::USERNAME} must be specified" if @options[Maze::Option::USERNAME].nil?
      @errors << "--#{Maze::Option::ACCESS_KEY} must be specified" if @options[Maze::Option::ACCESS_KEY].nil?
    end

    # Validates Local device options
    def validate_local

    end
  end
end
