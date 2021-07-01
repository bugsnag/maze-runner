# frozen_string_literal: true

require 'yaml'
require_relative '../option'
require_relative '../browser_stack_devices'

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
        if farm && !%w[bs cbt sl local bb].include?(farm)
          errors << "--#{Option::FARM} must be 'bs', 'cbt', 'sl' or 'local' if provided"
        end

        begin
          JSON.parse(options[Option::CAPABILITIES])
        rescue JSON::ParserError
          errors << "--#{Option::CAPABILITIES} must be valid JSON (given #{options[Option::CAPABILITIES]})"
        end

        # Farm specific options
        validate_bs options, errors if farm == 'bs'
        validate_sl options, errors if farm == 'sl'
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

          browsers = YAML.safe_load(File.read("#{__dir__}/../browsers_bs.yml"))

          unless browsers.include? browser
            browser_list = browsers.keys.join ', '
            errors << "Browser type '#{browser}' unknown on BrowserStack.  Must be one of: #{browser_list}."
          end
        elsif device
          device.each do |device_key|
            next if Maze::BrowserStackDevices::DEVICE_HASH.key? device_key
            errors << "Device type '#{device_key}' unknown on BrowserStack.  Must be one of #{Maze::BrowserStackDevices::DEVICE_HASH.keys}"
          end
          # App
          app = Maze::Helper.read_at_arg_file options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            # TODO: What about Sauce Labs URLs?
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

      # Validates Sauce Labs options
      def validate_sl(options, errors)
        # SL local binary
        sl_local = Maze::Helper.expand_path options[Option::SL_LOCAL]
        errors << "Sauce Connect binary '#{sl_local}' not found" unless File.exist? sl_local

        # Device
        browser = options[Option::BROWSER]
        device = options[Option::DEVICE]
        os = options[Option::OS]
        os_version = options[Option::OS_VERSION]
        if browser.nil? && device.nil? && os.nil? && os_version.nil?
          errors << 'A device or browser option must be specified'
        elsif browser
          errors << 'Browsers not yet implemented on Sauce Labs'
        else
          # App
          app = options[Option::APP]
          if app.nil?
            errors << "--#{Option::APP} must be provided when running on a device"
          else
            uuid_regex = /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/
            unless uuid_regex.match? app
              app = Maze::Helper.expand_path app
              errors << "app file '#{app}' not found" unless File.exist?(app)
            end
          end

          # OS
          if options[Option::OS].nil?
            errors << "--#{Option::OS} must be specified"
          else
            os = options[Option::OS].downcase
            errors << 'os must be android or ios' unless %w[android ios].include? os
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

        # Credentials
        errors << "--#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
        errors << "--#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?
      end

      # Validates BitBar device options
      def validate_bitbar(options, errors)
        errors << "--#{Option::BITBAR_API_KEY} must be specified" if options[Option::BITBAR_API_KEY].nil?

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
