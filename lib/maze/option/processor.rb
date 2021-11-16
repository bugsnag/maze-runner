# frozen_string_literal: true

require_relative '../option'
require_relative '../browser_stack_devices'

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
          config.bind_address = options[Maze::Option::BIND_ADDRESS]
          config.port = options[Maze::Option::PORT]

          # General options
          config.enable_retries = options[Maze::Option::ENABLE_RETRIES]

          # Document server options
          config.document_server_root = options[Maze::Option::DS_ROOT]
          config.document_server_bind_address = options[Maze::Option::DS_BIND_ADDRESS]
          config.document_server_port = options[Maze::Option::DS_PORT]

          # Logger options
          config.file_log = options[Maze::Option::FILE_LOG]
          config.log_requests = options[Maze::Option::LOG_REQUESTS] || !ENV['BUILDKITE'].nil?
          config.always_log = options[Maze::Option::ALWAYS_LOG]

          # General appium options
          config.appium_session_isolation = options[Maze::Option::SEPARATE_SESSIONS]
          config.app = Maze::Helper.read_at_arg_file options[Maze::Option::APP]
          config.resilient = options[Maze::Option::RESILIENT]
          farm = options[Maze::Option::FARM]
          config.farm = case farm
                        when nil then :none
                        when 'bs' then :bs
                        when 'sl' then :sl
                        when 'local' then :local
                        else
                          raise "Unknown farm '#{farm}'"
                        end
          config.locator = options[Maze::Option::A11Y_LOCATOR] ? :accessibility_id : :id
          config.capabilities_option = options[Maze::Option::CAPABILITIES]

          # Farm specific options
          case config.farm
          when :bs then
            if device_option = options[Maze::Option::DEVICE]
              pp device_option
              if device_option.is_a?(Array)
                config.device = device_option.first
                config.device_list = device_option
              else
                config.device = device_option
                config.device_list = []
              end
              config.os_version = Maze::BrowserStackDevices::DEVICE_HASH[config.device]['os_version'].to_f
            else
              config.browser = options[Maze::Option::BROWSER]
            end
            config.bs_local = Maze::Helper.expand_path(options[Maze::Option::BS_LOCAL])
            config.appium_version = options[Maze::Option::APPIUM_VERSION]
            username = config.username = options[Maze::Option::USERNAME]
            access_key = config.access_key = options[Maze::Option::ACCESS_KEY]
            config.appium_server_url = "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
          when :sl then
            config.device = options[Maze::Option::DEVICE]
            config.browser = options[Maze::Option::BROWSER]
            config.os = options[Maze::Option::OS]
            config.os_version = options[Maze::Option::OS_VERSION]
            config.sl_local = Maze::Helper.expand_path(options[Maze::Option::SL_LOCAL])
            config.appium_version = options[Maze::Option::APPIUM_VERSION]
            username = config.username = options[Maze::Option::USERNAME]
            access_key = config.access_key = options[Maze::Option::ACCESS_KEY]
            config.appium_server_url = "http://#{username}:#{access_key}@ondemand.us-west-1.saucelabs.com/wd/hub"
          when :local then
            if options[Maze::Option::BROWSER]
              config.browser = options[Maze::Option::BROWSER]
            else
              os = config.os = options[Maze::Option::OS].downcase
              config.os_version = options[Maze::Option::OS_VERSION].to_f
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
