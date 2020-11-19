# frozen_string_literal: true

module Maze
  # Processes the parsed command line options
  class OptionProcessor
    class << self
      # Populates config from the parsed options given
      # @param config [Configuration] MazeRunner configuration to populate
      # @param options [Hash] Parsed command line options
      def populate(config, options)
        config.appium_session_isolation = options[Option::SEPARATE_SESSIONS]
        config.app_location = options[Option::APP]
        config.resilient = options[Option::RESILIENT]
        farm = options[Option::FARM]
        config.farm = case farm
                      when nil then :none
                      when 'bs' then :bs
                      when 'local' then :local
                      else
                        raise "Unknown farm '#{farm}'"
                      end
        config.locator = options[Option::A11Y_LOCATOR] ? :accessibility_id : :id

        # Farm specific options
        case config.farm
        when :bs then
          raise "option --#{Option::USERNAME} must be specified" if options[Option::USERNAME].nil?
          raise "option --#{Option::ACCESS_KEY} must be specified" if options[Option::ACCESS_KEY].nil?

          bs_device = options[Option::BS_DEVICE]
          raise "option --#{Option::BS_DEVICE} must be specified" if bs_device.nil?
          unless Devices::DEVICE_HASH.key? bs_device
            raise "Device type '#{bs_device}' not known on BrowserStack.  Must be one of #{Devices::DEVICE_HASH.keys}"
          end

          config.bs_device = bs_device
          config.os_version = Devices::DEVICE_HASH[config.bs_device]['os_version'].to_f
          config.bs_local = options[Option::BS_LOCAL]
          config.appium_version = options[Option::BS_APPIUM_VERSION]
          username = config.username = options[Option::USERNAME]
          access_key = config.access_key = options[Option::ACCESS_KEY]
          config.appium_server_url = "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
        when :local then
          raise "option --#{Option::OS} must be specified" if options[Option::OS].nil?
          raise "option --#{Option::OS_VERSION} must be specified" if options[Option::OS_VERSION].nil?
          # Ensure OS version is a valid float so that notifier tests can perform numeric checks, e.g:
          # 'MazeRunner.config.os_version > 7'
          unless /^[1-9][0-9]*(\.[0-9])?/.match? options[Option::OS_VERSION]
            raise "option --#{Option::OS_VERSION} must be a valid OS version matching '/^[1-9][0-9]*(\\.[0-9])?/'"
          end

          os = MazeRunner.config.os = options[Option::OS].downcase
          MazeRunner.config.os_version = options[Option::OS_VERSION].to_f
          raise 'os must be ios or android' unless %w[ios android].include? os

          config.appium_server_url = options[Option::APPIUM_SERVER]
          if os == 'ios'
            raise 'option --apple-team-id must be specified for iOS' if options[Option::APPLE_TEAM_ID].nil?
            raise 'option --udid must be specified for iOS' if options[Option::UDID].nil?

            config.apple_team_id = options[Option::APPLE_TEAM_ID]
            config.device_id = options[Option::UDID]
          end
        when :none
          # Nothing to do
        else
          raise "Unexpected farm option #{config.farm}"
        end
      end
    end
  end
end
