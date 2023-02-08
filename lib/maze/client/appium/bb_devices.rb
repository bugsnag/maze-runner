# frozen_string_literal: true
require 'json'

module Maze
  module Client
    module Appium
      # Provides a source of capabilities used to run tests against specific BitBar devices
      # noinspection RubyStringKeysInHashInspection
      class BitBarDevices
        BASE_URI = 'https://cloud.bitbar.com/api/v2/me'

        class << self
          # Uses the BitBar API to find an available device from the group name given
          # @param device_group_name [String] Name of the device group for which to find an availavble device
          # @return Capabilities hash for the available device
          def get_available_device(device_group_name)
            device_group_id = get_device_group_id(device_group_name)
            $logger.debug "Got group id #{device_group_id} for #{device_group_name}"
            group_count, device = find_device_in_group(device_group_id)
            if device.nil?
              # TODO: Retry rather than fail, see PLAT-7377
              raise 'There are no devices available'
            else
              $logger.info "#{group_count} device(s) currently available in group '#{device_group_name}'"
            end

            device_name = device['displayName']
            platform = device['platform'].downcase
            platform_version = device['softwareVersion']['releaseVersion']

            $logger.info "Device   : #{device_name}"
            $logger.info "Platform : #{platform}"
            $logger.info "Version  : #{platform_version}"

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

          # Get the id of a device group given its name
          def get_device_group_id(device_group_name)
            query = {
              'filter': "displayName_eq_#{device_group_name}"
            }
            devices = query_api('device-groups', query)
            if devices['data'].size != 1
              $logger.error "Expected exactly one group with name #{device_group_name}, found #{devices.size}"
              raise "Failed to find a device group named '#{device_group_name}'"
            end
            devices['data'][0]['id']
          end

          def find_device_in_group(device_group_id)
            path = "device-groups/#{device_group_id}/devices"
            query = {
              'filter': "online_eq_true"
            }
            all_devices = query_api(path, query)

            $logger.debug "All available devices in group #{device_group_id}: #{JSON.pretty_generate(all_devices)}"
            filtered_devices = all_devices['data'].reject { |device| device['locked'] }
            return filtered_devices.size, filtered_devices.sample
          end

          # Queries the BitBar REST API
          def query_api(path, query)
            encoded_query = URI.encode_www_form(query)
            uri = URI("#{BASE_URI}/#{path}?#{encoded_query}")
            request = Net::HTTP::Get.new(uri)
            request.basic_auth(Maze.config.access_key, '')

            res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
              http.request(request)
            end

            JSON.parse(res.body)
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
                'device' => device
              }
            }.freeze
          end
        end
      end
    end
  end
end
