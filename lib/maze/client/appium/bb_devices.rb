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
              if device_group_ids.size > 1
                group_id = false
                group_count, device = api_client.find_device_in_groups(device_group_ids)
                if device.nil?
                  raise 'There are no devices available'
                else
                  $logger.info "#{group_count} device(s) currently available in group(s) '#{device_or_group_names}'"
                end
              else
                # Since there is only one group, we can use it verbatim
                $logger.info "Using device group #{device_or_group_names}"
                group_id = true
                device_name = device_group_ids.first
              end
            else
              # See if there is a device with the given name
              device = api_client.find_device device_or_group_names
            end

            # If a single device has been identified use that to determine other characteristics
            if device
              device_name = device['displayName']
              platform = device['platform'].downcase
              platform_version = device['softwareVersion']['releaseVersion']

              $logger.info "Selected device: #{device_name} (#{platform} #{platform_version})"
            else
              # If a device group has been identified, extrapolate characteristics from the group name
              if android_match = Regexp.new('(ANDROID|android)_(\d{1,2})').match(device_name)
                platform = 'android'
                platform_version = android_match[2]
              elsif ios_match = Regexp.new('(IOS|ios)_(\d{1,2})').match(device_name)
                platform = 'ios'
                platform_version = ios_match[2]
              end

              $logger.info "Selected device group: #{device_name} (#{platform} #{platform_version})"
            end

            # TODO: Setting the config here is rather a side effect and factoring it out would be better.
            #   For now, though, it means not having to provide the --os and --os-version options on the command line.
            Maze.config.os = platform
            Maze.config.os_version = platform_version.to_f.floor

            case platform
            when 'android'
              make_android_hash(device_name, group_id)
            when 'ios'
              make_ios_hash(device_name, group_id)
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

          def android_base_hash
            # Tripling up on capabilities in the `appium:options`, `appium` sub dictionaries and base dictionary.
            # See PLAT-11087
            appium_options = {
              'automationName' => 'UiAutomator2',
              'autoGrantPermissions' => true,
              'uiautomator2ServerInstallTimeout' => 60000,
              'uiautomator2ServerLaunchTimeout' => 60000
            }
            appium_options['appActivity'] = Maze.config.app_activity unless Maze.config.app_activity.nil?
            appium_options['appPackage'] = Maze.config.app_package unless Maze.config.app_package.nil?
            hash = {
              'platformName' => 'Android',
              'deviceName' => 'Android Phone',
              'appium:options' => appium_options,
              'appium' => appium_options
            }
            hash.merge!(appium_options)
            hash.dup
          end

          def make_android_hash(device, group_id = false)
            hash = android_base_hash
            if group_id
              hash['bitbar:options'] = {
                'deviceGroupId' => device
              }
            else
              hash['bitbar:options'] = {
                'device' => device
              }
            end
            hash.freeze
          end

          def ios_base_hash
            # Tripling up on capabilities in the `appium:options`, `appium` sub dictionaries and base dictionary.
            # See PLAT-11087
            appium_options = {
              'automationName' => 'XCUITest',
              'shouldTerminateApp' => 'true',
              'autoAcceptAlerts' => 'true'
            }
            hash = {
              'platformName' => 'iOS',
              'deviceName' => 'iPhone device',
              'appium:options' => appium_options,
              'appium' => appium_options
            }
            hash.merge!(appium_options)
            hash.dup
          end

          def make_ios_hash(device, group_id = false)
            hash = ios_base_hash
            if group_id
              hash['bitbar:options'] = {
                'deviceGroupId' => device
              }
            else
              hash['bitbar:options'] = {
                'device' => device
              }
            end
            hash.freeze
          end
        end
      end
    end
  end
end
