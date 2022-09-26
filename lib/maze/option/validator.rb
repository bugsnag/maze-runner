# frozen_string_literal: true

require 'yaml'
require_relative '../option'

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
        if farm && !%w[bs local bb].include?(farm)
          errors << "--#{Option::FARM} must be 'bs', 'bb' or 'local' if provided"
        end

        begin
          JSON.parse(options[Option::CAPABILITIES])
        rescue JSON::ParserError
          errors << "--#{Option::CAPABILITIES} must be valid JSON (given #{options[Option::CAPABILITIES]})"
        end

        # Farm specific options
        validate_bs options, errors if farm == 'bs'
        validate_bitbar options, errors if farm == 'bb'
        validate_local options, errors if farm == 'local'

        errors
      end

      # Validates BrowserStack options
      def validate_bs(options, errors)
        # BS local binary
        bs_local = Maze::Helper.expand_path options[Option::BS_LOCAL]
        errors << "BrowserStack local binary '#{bs_local}' not found" unless File.exist? bs_local

        # Device
        browser = options[Option::BROWSER]
        device = options[Option::DEVICE]
        if browser.nil? && device.empty?
          errors << "Either --#{Option::BROWSER} or --#{Option::DEVICE} must be specified"
        elsif browser

          browsers = YAML.safe_load(File.read("#{__dir__}/../client/selenium/bs_browsers.yml"))

          unless browsers.include? browser
            browser_list = browsers.keys.join ', '
            errors << "Browser type '#{browser}' unknown on BrowserStack.  Must be one of: #{browser_list}."
          end
        elsif device
          device.each do |device_key|
            next if Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH.key? device_key
            errors << "Device type '#{device_key}' unknown on BrowserStack.  Must be one of #{Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH.keys}"
          end
          # App
          app = Maze::Helper.read_at_arg_file options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            unless app.start_with?('bs://')
              app = Maze::Helper.expand_path app
              errors << "app file '#{app}' not found" unless File.exist?(app)
            end
          end
        end

        # Credentials
        errors << "--#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
        errors << "--#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?
      end

      # Validates BitBar device options
      def validate_bitbar(options, errors)
        if ENV['BUILDKITE']
          errors << "--#{Option::TMS_URI} must be specified when running on Buildkite" if options[Option::TMS_URI].nil?
        else
          errors << "--#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
          errors << "--#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?
        end

        # Device
        browser = options[Option::BROWSER]
        device = options[Option::DEVICE]
        if browser.nil? && device.empty?
          errors << "Either --#{Option::BROWSER} or --#{Option::DEVICE} must be specified"
        elsif browser
          browsers = YAML.safe_load(File.read("#{__dir__}/../client/selenium/bb_browsers.yml"))

          unless browsers.include? browser
            browser_list = browsers.keys.join ', '
            errors << "Browser type '#{browser}' unknown on BitBar.  Must be one of: #{browser_list}."
          end
        elsif device
          app = options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            uuid_regex = /\A[0-9]+\z/
            unless uuid_regex.match? app
              app = Maze::Helper.expand_path app
              errors << "app file '#{app}' not found" unless File.exist?(app)
            end
          end
        end
      end

      # Validates Local device options
      def validate_local(options, errors)
        if options[Option::BROWSER].nil?
          errors << "--#{Option::APP} must be specified" if options[Option::APP].nil?

          # OS
          if options[Option::OS].nil?
            errors << "--#{Option::OS} must be specified"
          else
            os = options[Option::OS].downcase
            errors << 'os must be android, ios, macos or windows' unless %w[android ios macos windows].include? os
            if os == 'ios'
              errors << "--#{Option::APPLE_TEAM_ID} must be specified for iOS" if options[Option::APPLE_TEAM_ID].nil?
              errors << "--#{Option::UDID} must be specified for iOS" if options[Option::UDID].nil?
            end
          end

          # OS Version
          unless options[Option::OS_VERSION].nil?
            # Ensure OS version is a valid float so that notifier tests can perform numeric checks
            # e.g 'Maze.config.os_version > 7'
            unless /^[1-9][0-9]*(\.[0-9])?/.match? options[Option::OS_VERSION]
              errors << "--#{Option::OS_VERSION} must be a valid version matching '/^[1-9][0-9]*(\\.[0-9])?/'"
            end
          end
        else
          # TODO Validate browser options
        end
      end
    end
  end
end
