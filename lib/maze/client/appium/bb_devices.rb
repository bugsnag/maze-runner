# frozen_string_literal: true
require 'json'

module Maze
  module Client
    module Appium
      # Provides a source of capabilities used to run tests against specific BitBar devices
      # noinspection RubyStringKeysInHashInspection
      class BitBarDevices
        class << self
          # Uses the BitBar API to find an available device from the group name given, or a device of that name
          # @param device_or_group_names [String] Name of the device, or device group(s) for which to find an available
          # device.  Multiple device group names can be separated by a pipe.
          # @return Capabilities hash for the available device
          def get_available_device(device_or_group_names)
            api_client = BitBarApiClient.new(Maze.config.access_key)
            device_group_ids = api_client.get_device_group_ids(device_or_group_names)
            if device_group_ids
              # Device group found - find a free device in it
              $logger.trace "Got group ids #{device_group_ids} for #{device_or_group_names}"
              group_count, device = api_client.find_device_in_groups(device_group_ids)
              if device.nil?
                # TODO: Retry rather than fail, see PLAT-7377
                Maze::Helper.error_exit 'There are no devices available'
              else
                $logger.info "#{group_count} device(s) currently available in group(s) '#{device_or_group_names}'"
              end
            else
              # See if there is a device with the given name
              device = api_client.find_device device_or_group_names
            end

            device_name = device['displayName']
            platform = device['platform'].downcase
            platform_version = device['softwareVersion']['releaseVersion']

            $logger.info "Selected device: #{device_name} (#{platform} #{platform_version})"

            # TODO: Setting the config here is rather a side effect and factoring it out would be better.
            #   For now, though, it means not having to provide the --os and --os-version options on the command line.
            Maze.config.os = platform
            Maze.config.os_version = platform_version.to_f.floor

            prefix = caps_prefix(Maze.config.appium_version)

            case platform
            when 'android'
              automation_name = if platform_version.start_with?('5')
                                  'UiAutomator1'
                                else
                                  'UiAutomator2'
                                end
              make_android_hash(device_name, automation_name)
            when 'ios'
              make_ios_hash(device_name, prefix)
            else
              throw "Invalid device platform specified #{platform}"
            end
          end

          def list_device_groups(access_key)
            api_client = BitBarApiClient.new(access_key)
            device_groups = api_client.get_device_group_list
            unless device_groups['data'] && !device_groups['data'].empty?
              puts 'There are no device groups available for the given user access key'
              exit 1
            end
            puts "BitBar device groups available:"
            device_groups['data'].sort_by{|g| g['displayName']}.each do |group|
              puts '------------------------------'
              puts "Group name   : #{group['displayName']}"
              puts "OS           : #{group['osType']}"
              puts "Device count : #{group['deviceCount']}"
            end
          end

          def list_devices_for_group(device_group, access_key)
            api_client = BitBarApiClient.new(access_key)
            group_id = api_client.get_device_group_id(device_group)
            unless group_id
              puts "No device groups were found with the given name #{device_group}"
              return
            end
            devices = api_client.get_device_list_for_group(group_id)
            if devices['data'].empty?
              puts "There are no devices available for the #{device_group} device group"
              return
            end
            puts "BitBar devices available for device group #{device_group}:"
            devices['data'].sort_by{|d| d['displayName']}.each do |device|
              puts '------------------------------'
              puts "Device name : #{device['displayName']}"
              puts "OS          : #{device['platform']} #{device['softwareVersion']['releaseVersion']}"

              if device['platform'].eql? 'ANDROID'
                puts "API level   : #{device['softwareVersion']['apiLevel']}"
              end
            end
          end

          def make_android_hash(device, automation_name)
            hash = {
              'automationName' => automation_name,
              'platformName' => 'Android',
              'deviceName' => 'Android Phone',
              'bitbar:options' => {
                'appium:autoGrantPermissions' => true,
                'device' => device,
              }
            }
            hash.freeze
          end

          def make_ios_hash(device, prefix='')
            {
              'automationName' => 'XCUITest',
              'deviceName' => 'iPhone device',
              'platformName' => 'iOS',
              "#{prefix}shouldTerminateApp" => 'true',
              'bitbar:options' => {
                'device' => device
              }
            }.freeze
          end

          def caps_prefix(appium_version)
            appium_version.nil? || (appium_version.to_i < 2) ? '' : 'appium:'
          end
        end
      end
    end
  end
end
