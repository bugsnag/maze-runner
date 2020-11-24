# frozen_string_literal: true

require_relative 'option'
require_relative '../features/support/capabilities/devices'

module Maze
  # Validates command line options
  class OptionValidator
    # Validates all provided options
    # @param options [Hash] Parsed command line options
    def validate(options)
      errors = []

      # Common options
      farm = options[Option::FARM]
      if farm && !%w[bs local].include?(farm)
        errors << "--#{Maze::Option::FARM} must be either 'bs' or 'local' if provided"
      end

      begin
        JSON.parse(options[Option::CAPABILITIES])
      rescue JSON::ParserError
        errors << "--#{Maze::Option::CAPABILITIES} must be valid JSON (given #{options[Option::CAPABILITIES]})"
      end

      # Farm specific options
      validate_bs options, errors if farm == 'bs'
      validate_local options, errors if farm == 'local'

      errors
    end

    # Validates BrowserStack options
    def validate_bs(options, errors)
      errors << "--#{Maze::Option::APP} must be specified" if options[Maze::Option::APP].nil?
      bs_device = options[Maze::Option::BS_DEVICE]
      if bs_device.nil?
        errors << "--#{Maze::Option::BS_DEVICE} must be specified"
      else
        unless Devices::DEVICE_HASH.key? bs_device
          errors << "Device type '#{bs_device}' unknown on BrowserStack.  Must be one of #{Devices::DEVICE_HASH.keys}"
        end
      end
      errors << "--#{Maze::Option::USERNAME} must be specified" if options[Maze::Option::USERNAME].nil?
      errors << "--#{Maze::Option::ACCESS_KEY} must be specified" if options[Maze::Option::ACCESS_KEY].nil?
      # TODO: Check that the --bs-local option is valid (file exists)
      # TODO: Check that the --app option is valid (file exists)
    end

    # Validates Local device options
    def validate_local(options, errors)
      errors << "--#{Maze::Option::APP} must be specified" if options[Maze::Option::APP].nil?

      # OS
      if options[Maze::Option::OS].nil?
        errors << "--#{Maze::Option::OS} must be specified"
      else
        os = options[Maze::Option::OS].downcase
        errors << 'os must be android, ios or macos' unless %w[android ios macos].include? os
        if os == 'ios'
          if options[Maze::Option::APPLE_TEAM_ID].nil?
            errors << "--#{Maze::Option::APPLE_TEAM_ID} must be specified for iOS"
          end
          errors << "--#{Maze::Option::UDID} must be specified for iOS" if options[Maze::Option::UDID].nil?
        end
      end

      # OS Version
      if options[Maze::Option::OS_VERSION].nil?
        errors << "--#{Maze::Option::OS_VERSION} must be specified"
      else
        # Ensure OS version is a valid float so that notifier tests can perform numeric checks
        # e.g 'MazeRunner.config.os_version > 7'
        unless /^[1-9][0-9]*(\.[0-9])?/.match? options[Maze::Option::OS_VERSION]
          errors << "--#{Maze::Option::OS_VERSION} must be a valid version matching '/^[1-9][0-9]*(\\.[0-9])?/'"
        end
      end
    end
  end
end
