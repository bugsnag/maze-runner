# frozen_string_literal: true
require 'json'

module Maze
  # Provides a source of capabilities used to run tests against specific BitBar devices
  # noinspection RubyStringKeysInHashInspection
  class BitBarDevices
    APPIUM_1_9_1 = '1.9.1'
    APPIUM_1_15_0 = '1.15.0'
    APPIUM_1_20_2 = '1.20.2'

    BASE_URI = 'https://cloud.bitbar.com/api/v2/me'
    FILTER_PATH = 'devices/filters'

    DEVICE_GROUP_IDS = {
      # Classic, non-specific devices for each Android version
      'ANDROID_10_0' => '46024',

      # iOS devices
      'IOS_14' => '46025'
    }

    class << self
      def call_bitbar_api(path, query, api_key)
        encoded_query = URI.encode_www_form(query)
        uri = URI("#{BASE_URI}/#{path}?#{encoded_query}")
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(api_key, '')

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        JSON.parse(res.body)
      end

      def get_filtered_device_name(device_group_id, api_key)
        path = "device-groups/#{device_group_id}/devices"
        query = {
          'filter': "online_eq_true"
        }
        all_devices = call_bitbar_api(path, query, api_key)
        $logger.info "all_devices: #{JSON.pretty_generate(all_devices)}"
        filtered_devices = all_devices['data'].reject { |device| device['locked'] }
        if filtered_devices.empty?
          $logger.error 'There are no devices available'
        else
          selected = filtered_devices.first['displayName']
          $logger.info "Selected #{selected} from #{filtered_devices.size} available device(s)"
          selected
        end
      end

      def get_device(device_group, platform, platform_version, api_key)
        device_group_id = DEVICE_GROUP_IDS[device_group]
        device_name = get_filtered_device_name(device_group_id, api_key)
        case platform.downcase
        when 'android'
          automation_name = if platform_version.start_with?('5')
                              'UiAutomator1'
                            else
                              'UiAutomator2'
                            end
          make_android_hash(device_name, nil, automation_name)
        when 'ios'
          make_ios_hash(device_name)
        else
          throw "Invalid device platform specified #{platform}"
        end
      end


      def make_android_hash(device, appium_version = nil, automation_name = nil)
        hash = {
          'platformName' => 'Android',
          'deviceName' => 'Android Phone',
          'bitbar:options' => {
            'device' => device,
            # 'bitbar_target' => 'android',
          }
        }
        # hash['bitbar_appiumVersion'] = appium_version if appium_version
        # hash['appium:automationName'] = automation_name if automation_name
        hash.freeze
      end

      def make_ios_hash(device)
        {
          'platformName' => 'iOS',
          'bitbar_device' => device,
          'bitbar_target' => 'ios',
          'deviceName' => 'iPhone device',
          'automationName' => 'XCUITest'
        }.freeze
      end
    end
  end
end
