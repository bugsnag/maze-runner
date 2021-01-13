# frozen_string_literal: true

require 'yaml'
require_relative '../option'
require_relative '../devices'

module Maze
  module Option
    # Validates command line options
    class Validator
      # Validates all provided options
      # @param options [Hash] Parsed command line options
      def validate(options)
        errors = []

        # Common options
        farm = options[Option::FARM]
        errors << "--#{Option::FARM} must be either 'bs' or 'local' if provided" if farm && !%w[bs local].include?(farm)

        begin
          JSON.parse(options[Option::CAPABILITIES])
        rescue JSON::ParserError
          errors << "--#{Option::CAPABILITIES} must be valid JSON (given #{options[Option::CAPABILITIES]})"
        end

        # Farm specific options
        validate_bs options, errors if farm == 'bs'
        validate_local options, errors if farm == 'local'

        errors
      end

      # Validates BrowserStack options
      def validate_bs(options, errors)
        # BS local binary
        bs_local = options[Option::BS_LOCAL]
        errors << "BrowserStack local binary '#{bs_local}' not found" unless File.exist? bs_local

        # Device
        bs_browser = options[Option::BS_BROWSER]
        bs_device = options[Option::BS_DEVICE]
        if bs_browser.nil? && bs_device.nil?
          errors << "Either --#{Option::BS_BROWSER} or --#{Option::BS_DEVICE} must be specified"
        elsif bs_browser

          browsers = YAML.safe_load(File.read("#{__dir__}/../browsers.yml"))

          unless browsers.include? bs_browser
            browser_list = browsers.keys.join ', '
            errors << "Browser type '#{bs_browser}' unknown on BrowserStack.  Must be one of: #{browser_list}."
          end
        elsif bs_device
          unless Maze::Devices::DEVICE_HASH.key? bs_device
            errors << "Device type '#{bs_device}' unknown on BrowserStack.  Must be one of #{Maze::Devices::DEVICE_HASH.keys}"
          end
          # App
          app = options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            errors << "app file '#{app}' not found" unless app.start_with?('bs://') || File.exist?(app)
          end
        end

        # Credentials
        errors << "--#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
        errors << "--#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?
      end

      # Validates Local device options
      def validate_local(options, errors)
        errors << "--#{Option::APP} must be specified" if options[Option::APP].nil?

        # OS
        if options[Option::OS].nil?
          errors << "--#{Option::OS} must be specified"
        else
          os = options[Option::OS].downcase
          errors << 'os must be android, ios or macos' unless %w[android ios macos].include? os
          if os == 'ios'
            errors << "--#{Option::APPLE_TEAM_ID} must be specified for iOS" if options[Option::APPLE_TEAM_ID].nil?
            errors << "--#{Option::UDID} must be specified for iOS" if options[Option::UDID].nil?
          end
        end

        # OS Version
        if options[Option::OS_VERSION].nil?
          errors << "--#{Option::OS_VERSION} must be specified"
        else
          # Ensure OS version is a valid float so that notifier tests can perform numeric checks
          # e.g 'Maze.config.os_version > 7'
          unless /^[1-9][0-9]*(\.[0-9])?/.match? options[Option::OS_VERSION]
            errors << "--#{Option::OS_VERSION} must be a valid version matching '/^[1-9][0-9]*(\\.[0-9])?/'"
          end
        end
      end
    end
  end
end
