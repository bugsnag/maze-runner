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
        filtered_devices = all_devices['data'].reject { |device| device['locked'] }
        filtered_devices.first['displayName']
      end

      def get_device(device_group, platform, platform_version, api_key)
        device_group_id = DEVICE_GROUP_IDS[device_group]
        device_name = get_filtered_device_name(device_group_id, api_key)
        device_caps = case platform.downcase
        when 'android'
          automationName = 'UiAutomator1' if platform_version.start_with?('5')
          make_android_hash(device_name, nil, automationName)
        when 'ios'
          make_ios_hash(device_name)
        else
          throw "Invalid device platform specified #{platform}"
        end
        device_caps
      end

      def make_android_hash(device, appium_version = nil, automationName = nil)
        hash = {
          'platformName' => 'Android',
          'bitbar_device' => device,
          'bitbar_target' => 'android',
          'deviceName' => 'Android Phone'
        }
        hash['bitbar_appiumVersion'] = appium_version if appium_version
        hash['automationName'] = automationName if automationName
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
