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
      if farm && !%w[bs local].include?(farm)
        @errors << "--#{Maze::Option::FARM} must be either 'bs' or 'local' if provided"
      end

      # Farm specific options
      validate_bs if farm == 'bs'
      validate_local if farm == 'local'

      @errors
    end

    # Validates BrowserStack options
    def validate_bs
      bs_device = options[Maze::Option::BS_DEVICE]
      @errors << "--#{Maze::Option::BS_DEVICE} must be specified" if bs_device.nil?
      unless Devices::DEVICE_HASH.key? bs_device
        @errors << "Device type '#{bs_device}' not known on BrowserStack.  Must be one of #{Devices::DEVICE_HASH.keys}"
      end
      @errors << "--#{Maze::Option::USERNAME} must be specified" if @options[Maze::Option::USERNAME].nil?
      @errors << "--#{Maze::Option::ACCESS_KEY} must be specified" if @options[Maze::Option::ACCESS_KEY].nil?
    end

    # Validates Local device options
    def validate_local
      if options[Maze::Option::OS].nil?
        @errors << "--#{Maze::Option::OS} must be specified"
      else
        os = config.os = options[Maze::Option::OS].downcase
        @errors << 'os must be ios or android' unless %w[ios android].include? os
      end

      @errors << "--#{Maze::Option::OS_VERSION} must be specified" if options[Maze::Option::OS_VERSION].nil?
      # Ensure OS version is a valid float so that notifier tests can perform numeric checks, e.g:
      # 'MazeRunner.config.os_version > 7'
      unless /^[1-9][0-9]*(\.[0-9])?/.match? options[Maze::Option::OS_VERSION]
        @errors << "option --#{Maze::Option::OS_VERSION} must be a valid version matching '/^[1-9][0-9]*(\\.[0-9])?/'"
      end

    end
  end
end
