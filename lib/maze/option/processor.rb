# frozen_string_literal: true

require_relative '../option'

module Maze
  module Option
    # Processes the parsed command line options
    class Processor
      class << self
        # Populates config from the parsed options given
        # @param config [Configuration] MazeRunner configuration to populate
        # @param options [Hash] Parsed command line options
        def populate(config, options)

          # Server options
          config.https = options[Maze::Option::HTTPS]
          config.bind_address = options[Maze::Option::BIND_ADDRESS]
          config.port = options[Maze::Option::PORT]
          config.null_port = options[Maze::Option::NULL_PORT]

          # General options
          config.aws_public_ip = options[Maze::Option::AWS_PUBLIC_IP]
          config.enable_retries = options[Maze::Option::RETRIES]
          config.enable_bugsnag = options[Maze::Option::BUGSNAG]
          config.aspecto_repeater_api_key = options[Maze::Option::ASPECTO_REPEATER_API_KEY]
          config.bugsnag_repeater_api_key = options[Maze::Option::BUGSNAG_REPEATER_API_KEY]

          # Document server options
          config.document_server_root = options[Maze::Option::DS_ROOT]
          config.document_server_bind_address = options[Maze::Option::DS_BIND_ADDRESS]
          config.document_server_port = options[Maze::Option::DS_PORT]

          # Logger options
          config.file_log = options[Maze::Option::FILE_LOG]
          config.log_requests = options[Maze::Option::LOG_REQUESTS] || !ENV['BUILDKITE'].nil?
          config.always_log = options[Maze::Option::ALWAYS_LOG]

          # General appium options
          config.app = Maze::Helper.read_at_arg_file options[Maze::Option::APP]
          farm = options[Maze::Option::FARM]
          config.farm = case farm
                        when nil then :none
                        when 'bs' then :bs
                        when 'bb' then :bb
                        when 'local' then :local
                        else
                          raise "Unknown farm '#{farm}'"
                        end
          config.locator = options[Maze::Option::A11Y_LOCATOR] ? :accessibility_id : :id
          config.capabilities_option = options[Maze::Option::CAPABILITIES]
          config.app_activity = options[Maze::Option::APP_ACTIVITY]
          config.app_package = options[Maze::Option::APP_PACKAGE]
          config.legacy_driver = !ENV['USE_LEGACY_DRIVER'].nil?
          config.start_tunnel = options[Maze::Option::TUNNEL]

          # Farm specific options
          case config.farm
          when :bs
            device_option = options[Maze::Option::DEVICE]
            if device_option.nil? || device_option.empty?
              config.browser = options[Maze::Option::BROWSER]
            else
              if device_option.is_a?(Array)
                config.device = device_option.first
                config.device_list = device_option.drop(1)
              else
                config.device = device_option
                config.device_list = []
              end
              if config.legacy_driver?
                config.os_version = Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH[config.device]['os_version'].to_f
              else
                config.os_version = Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH[config.device]['platformVersion'].to_f
              end
            end
            config.bs_local = Maze::Helper.expand_path(options[Maze::Option::BS_LOCAL])
            config.appium_version = options[Maze::Option::APPIUM_VERSION]
            username = config.username = options[Maze::Option::USERNAME]
            access_key = config.access_key = options[Maze::Option::ACCESS_KEY]
            config.appium_server_url = "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
          when :bb then
            config.username = options[Maze::Option::USERNAME]
            config.access_key = options[Maze::Option::ACCESS_KEY]
            config.appium_version = options[Maze::Option::APPIUM_VERSION]
            device_option = options[Maze::Option::DEVICE]
            if device_option.nil? || device_option.empty?
              # BitBar Web
              config.browser = options[Maze::Option::BROWSER]
              config.browser_version = options[Maze::Option::BROWSER_VERSION]
            else
              # BitBar Devices
              if device_option.is_a?(Array)
                config.device = device_option.first
                config.device_list = device_option.drop(1)
              else
                config.device = device_option
                config.device_list = []
              end
            end
            config.os = options[Maze::Option::OS]
            config.os_version = options[Maze::Option::OS_VERSION]
            config.sb_local = Maze::Helper.expand_path(options[Maze::Option::SB_LOCAL])
            config.appium_server_url = options[Maze::Option::APPIUM_SERVER]
            config.selenium_server_url = options[Maze::Option::SELENIUM_SERVER]
            config.app_bundle_id = options[Maze::Option::APP_BUNDLE_ID]
          when :local then
            if options[Maze::Option::BROWSER]
              config.browser = options[Maze::Option::BROWSER]
            else
              os = config.os = options[Maze::Option::OS].downcase
              config.os_version = options[Maze::Option::OS_VERSION].to_f unless options[Maze::Option::OS_VERSION].nil?
              config.appium_server_url = options[Maze::Option::APPIUM_SERVER]
              config.start_appium = options[Maze::Option::START_APPIUM]
              config.appium_logfile = options[Maze::Option::APPIUM_LOGFILE]
              if os == 'ios'
                config.apple_team_id = options[Maze::Option::APPLE_TEAM_ID]
                config.device_id = options[Maze::Option::UDID]
              end
            end
          when :none
            if options[Maze::Option::OS]
              config.os = options[Maze::Option::OS].downcase
            end
            if options[Maze::Option::OS_VERSION]
              config.os_version = options[Maze::Option::OS_VERSION].to_f
            end
          else
            raise "Unexpected farm option #{config.farm}"
          end
        end
      end
    end
  end
end
