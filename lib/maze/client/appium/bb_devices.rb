# frozen_string_literal: true
require 'json'

module Maze
  module Client
    module Appium
      # Provides a source of capabilities used to run tests against specific BitBar devices
      # noinspection RubyStringKeysInHashInspection
      class BitBarDevices
        class << self
          # Uses the BitBar API to find an available device from the group name given
          # @param device_group_name [String] Name of the device group for which to find an availavble device
          # @return Capabilities hash for the available device
          def get_available_device(device_group_name)
            api_client = BitBarApiClient.new
            device_group_id = api_client.get_device_group_id(device_group_name)
            $logger.debug "Got group id #{device_group_id} for #{device_group_name}"
            group_count, device = api_client.find_device_in_group(device_group_id)
            if device.nil?
              # TODO: Retry rather than fail, see PLAT-7377
              raise 'There are no devices available'
            else
              $logger.info "#{group_count} device(s) currently available in group '#{device_group_name}'"
            end

            device_name = device['displayName']
            platform = device['platform'].downcase
            platform_version = device['softwareVersion']['releaseVersion']

            $logger.info "Selected device: #{device_name} (#{platform} #{platform_version})"

            # TODO: Setting the config here is rather a side effect and factoring it out would be better.
            #   For now, though, it means not having to provide the --os and --os-version options on the command line.
            Maze.config.os = platform
            Maze.config.os_version = platform_version.to_f.floor

            case platform
            when 'android'
              automation_name = if platform_version.start_with?('5')
                                  'UiAutomator1'
                                else
                                  'UiAutomator2'
                                end
              make_android_hash(device_name, automation_name)
            when 'ios'
              make_ios_hash(device_name)
            else
              throw "Invalid device platform specified #{platform}"
            end
          end

          def make_android_hash(device, automation_name)
            hash = {
              'automationName' => automation_name,
              'platformName' => 'Android',
              'deviceName' => 'Android Phone',
              'bitbar:options' => {
                'device' => device
              }
            }
            hash.freeze
          end

          def make_ios_hash(device)
            {
              'automationName' => 'XCUITest',
              'deviceName' => 'iPhone device',
              'platformName' => 'iOS',
              'bitbar:options' => {
                'noReset' => 'true',
                'shouldTerminateApp' => 'true',
                'device' => device
              }
            }.freeze
          end
        end
      end
    end
  end
end
