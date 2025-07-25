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

        #
        # Common options
        #

        # --farm
        farm = options[Option::FARM]
        if farm && !%w[bs local bb].include?(farm)
          errors << "--#{Option::FARM} must be 'bs', 'bb' or 'local' if provided"
        end

        # --capabilities
        begin
          JSON.parse(options[Option::CAPABILITIES])
        rescue JSON::ParserError
          errors << "--#{Option::CAPABILITIES} must be valid JSON (given #{options[Option::CAPABILITIES]})"
        end

        # --repeater-api-key
        key = options[Option::BUGSNAG_REPEATER_API_KEY]
        if key&.empty?
          $logger.warn "A repeater-api-key option was provided with an empty string. This won't be used during this test run"
          key = nil
        end
        key_regex = /^[0-9a-fA-F]{32}$/

        if key && !key_regex.match?(key)
          errors << "--#{Option::BUGSNAG_REPEATER_API_KEY} must be set to a 32-character hex value"
        end

        # --hub-repeater-api-key
        key = options[Option::HUB_REPEATER_API_KEY]
        if key&.empty?
          $logger.warn "A hub-repeater-api-key option was provided with an empty string. This won't be used during this test run"
          key = nil
        end
        key_regex = /^[0-9a-fA-F]{32}$/

        if key && !key_regex.match?(key)
          errors << "--#{Option::HUB_REPEATER_API_KEY} must be set to a 32-character hex value"
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
        if browser.empty? && device.empty?
          errors << "Either --#{Option::BROWSER} or --#{Option::DEVICE} must be specified"
        elsif !browser.empty?
          browsers = YAML.safe_load(File.read("#{__dir__}/../client/selenium/bs_browsers.yml"))

          rejected_browsers = browser.reject { |br| browsers.include? br }
          unless rejected_browsers.empty?
            browser_list = browsers.keys.join ', '
            errors << "Browser types '#{rejected_browsers.join(', ')}' unknown on BrowserStack.  Must be one of: #{browser_list}."
          end
        elsif !device.empty?
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
        browser = options[Option::BROWSER]
        device = options[Option::DEVICE]

        errors << "--#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
        errors << "--#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?

        # Device
        if browser.empty? && device.empty?
          errors << "Either --#{Option::BROWSER} or --#{Option::DEVICE} must be specified"
        elsif !browser.empty? && device.empty?
          # Desktop browsers (Selenium)
          browsers = YAML.safe_load(File.read("#{__dir__}/../client/selenium/bb_browsers.yml"))

          rejected_browsers = browser.reject { |br| browsers.include? br }
          if rejected_browsers.empty?
            if options[Option::BROWSER_VERSION].nil?
              browser.each do |br|
                next if browsers[br].include?('browserVersion')
                errors << "--#{Option::BROWSER_VERSION} must be specified for browser '#{br}'"
              end
            end
          else
            browser_list = browsers.keys.join ', '
            errors << "Browser types '#{rejected_browsers.join(', ')}' unknown on BitBar.  Must be one of: #{browser_list}."
          end

        elsif browser.empty? && !device.empty?
          # Mobile app testing
          app = Maze::Helper.read_at_arg_file options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            uuid_regex = /\A[0-9]+\z/
            unless uuid_regex.match? app
              app = Maze::Helper.expand_path app
              errors << "app file '#{app}' not found" unless File.exist?(app)
            end
          end
        else
          # TODO - Mobile browser testing
        end
      end

      # Validates Local device options
      def validate_local(options, errors)
        if options[Option::BROWSER].empty?
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
