# frozen_string_literal: true

require 'yaml'
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
      # BS local binary
      bs_local = options[Maze::Option::BS_LOCAL]
      errors << "BrowserStack local binary '#{bs_local}' not found" unless File.exist? bs_local

      # Device
      bs_browser = options[Maze::Option::BS_BROWSER]
      bs_device = options[Maze::Option::BS_DEVICE]
      if bs_browser.nil? && bs_device.nil?
        errors << "Either --#{Maze::Option::BS_BROWSER} or --#{Maze::Option::BS_DEVICE} must be specified"
      elsif bs_browser

        browsers = YAML.safe_load(File.read("#{__dir__}/../features/support/capabilities/browsers.yml"))

        unless browsers.include? bs_browser
          browser_list = browsers.keys.join ', '
          errors << "Browser type '#{bs_browser}' unknown on BrowserStack.  Must be one of: #{browser_list}."
        end
      elsif bs_device
        unless Devices::DEVICE_HASH.key? bs_device
          errors << "Device type '#{bs_device}' unknown on BrowserStack.  Must be one of #{Devices::DEVICE_HASH.keys}"
        end
        # App
        app = options[Maze::Option::APP]
        if app.nil?
          errors << "--#{Maze::Option::APP} must be provided when running on a device"
        else
          errors << "app file '#{app}' not found" unless app.start_with?('bs://') || File.exist?(app)
        end
      end

      # Credentials
      errors << "--#{Maze::Option::USERNAME} must be specified" if options[Maze::Option::USERNAME].nil?
      errors << "--#{Maze::Option::ACCESS_KEY} must be specified" if options[Maze::Option::ACCESS_KEY].nil?
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
