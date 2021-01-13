# frozen_string_literal: true

require_relative '../option'
require_relative '../devices'

module Maze
  module Option
    # Processes the parsed command line options
    class Processor
      class << self
        # Populates config from the parsed options given
        # @param config [Configuration] MazeRunner configuration to populate
        # @param options [Hash] Parsed command line options
        def populate(config, options)
          config.appium_session_isolation = options[Maze::Option::SEPARATE_SESSIONS]
          config.app = options[Maze::Option::APP]
          config.resilient = options[Maze::Option::RESILIENT]
          farm = options[Maze::Option::FARM]
          config.farm = case farm
                        when nil then :none
                        when 'bs' then :bs
                        when 'local' then :local
                        else
                          raise "Unknown farm '#{farm}'"
                        end
          config.locator = options[Maze::Option::A11Y_LOCATOR] ? :accessibility_id : :id
          config.capabilities_option = options[Maze::Option::CAPABILITIES]

          # Farm specific options
          case config.farm
          when :bs then
            if options[Maze::Option::BS_DEVICE]
              config.bs_device = options[Maze::Option::BS_DEVICE]
              config.os_version = Maze::Devices::DEVICE_HASH[config.bs_device]['os_version'].to_f
            else
              config.bs_browser = options[Maze::Option::BS_BROWSER]
            end
            config.bs_local = options[Maze::Option::BS_LOCAL]
            config.appium_version = options[Maze::Option::BS_APPIUM_VERSION]
            username = config.username = options[Maze::Option::USERNAME]
            access_key = config.access_key = options[Maze::Option::ACCESS_KEY]
            config.appium_server_url = "http://#{username}:#{access_key}@hub-cloud.browserstack.com/wd/hub"
          when :local then
            os = config.os = options[Maze::Option::OS].downcase
            config.os_version = options[Maze::Option::OS_VERSION].to_f
            config.appium_server_url = options[Maze::Option::APPIUM_SERVER]
            if os == 'ios'
              config.apple_team_id = options[Maze::Option::APPLE_TEAM_ID]
              config.device_id = options[Maze::Option::UDID]
            end
          when :none
            nil
          else
            raise "Unexpected farm option #{config.farm}"
          end
        end
      end
    end
  end
end
