# frozen_string_literal: true
require 'json'

module Maze
  # Provides a source of capabilities used to run tests against specific BitBar devices
  # noinspection RubyStringKeysInHashInspection
  class BitBarDevices
    APPIUM_1_9_1 = '1.9.1'
    APPIUM_1_15_0 = '1.15.0'
    APPIUM_1_20_2 = '1.20.2'

    BASE_URI = 'https://cloud.bitbar.com/api/v2'
    FILTER_PATH = 'devices/filters'
    DEVICES_PATH = 'devices'

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

      def get_filter_ids(platform, platform_version, api_key)
        query = {
          'filter': "deviceFilterGroup.name_eq_#{platform} version"
        }
        all_filters = call_bitbar_api(FILTER_PATH, query, api_key)
        filter_array = all_filters['deviceFilterGroups'].first
        target_filters = filter_array['deviceFilters'].filter do |filter|
          filter['displayName'].start_with?(platform_version)
        end
        target_filters.map { |filter| filter['id'] }
      end

      def get_filtered_device_name(platform, filter_ids, api_key)
        query = {
          'filter': "online_eq_true",
          'labelIds[]': filter_ids,
          'limit': 100
        }
        all_devices = call_bitbar_api(DEVICES_PATH, query, api_key)
        sorted_devices = all_devices['data'].sort_by do |device|
          device['softwareVersion']['releaseVersion']
        end
        target_device = sorted_devices.last
        target_device['displayName']
      end

      def get_device(platform, platform_version, api_key)
        filter_ids = get_filter_ids(platform, platform_version, api_key)
        device_name = get_filtered_device_name(platform, filter_ids, api_key)
        if platform.downcase == 'android'
          make_android_hash(device_name)
        elsif platform.downcase == 'ios'
          make_ios_hash(device_name)
        else
          # Throw a wobbly
          throw "Invalid device platform specified #{platform}"
        end
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

      def add_android(device, version, hash, appium_version = nil)
        # Key format is "ANDROID_<version>_<device>", with:
        # - dots in versions and all spaces replaced with underscores
        # - device made upper case
        name = device.upcase.gsub ' ', '_'
        new_version = version.gsub '.', '_'
        key = "ANDROID_#{new_version}_#{name}"
        hash[key] = make_android_hash device, appium_version
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

      def add_ios(device, version, hash)
        # Key format is "IOS_<version>_<device>", with:
        # - dots in versions and all spaces replaced with underscores
        # - device made upper case
        name = device.upcase.gsub ' ', '_'
        name = name.gsub '.', '_'
        new_version = version.gsub '.', '_'
        key = "IOS_#{new_version}_#{name}"
        hash[key] = make_ios_hash device
      end

      def create_hash
        hash = {
          # Classic, non-specific devices for each Android version
          'ANDROID_11_0' => make_android_hash('Google Pixel 4 -US'),
          'ANDROID_10_0' => make_android_hash('Google Pixel 2 Android 10'),
          'ANDROID_9_0' => make_android_hash('Google Pixel Android 9'),
          'ANDROID_8_1' => make_android_hash('Google Pixel 2 8.1 -US'),
          'ANDROID_8_0' => make_android_hash('Google Pixel 8.0 -EU'),
          'ANDROID_7_1' => make_android_hash('Motorola Google Nexus 6 7.1.1'),
          'ANDROID_7_0' => make_android_hash('Motorola Moto G4'),
          'ANDROID_6_0' => make_android_hash('Samsung Galaxy S5 SM-G900F'),
          'ANDROID_5_1' => make_android_hash('Asus Google Nexus 7 2013 5.1.1'),
          'ANDROID_5_0' => make_android_hash('Samsung Galaxy A7 SM-A700F'),
          'ANDROID_4_4' => make_android_hash('Motorola Moto X Ghost XT1056', nil, 'UiAutomator1'),

          # iOS devices
          'IOS_14' => make_ios_hash('iPhone 12 A2172 14.7 -US'),
          'IOS_13' => make_ios_hash('Apple iPhone 11 Pro 13.7 -US'),
          'IOS_12' => make_ios_hash('Apple iPhone 6 A1586 12.4.9'),
          'IOS_11' => make_ios_hash('Apple iPhone 7 A1660 11.4.1 -US'),
          'IOS_10' => make_ios_hash('Apple iPhone 6S Plus A1687 10.2'),
          'IOS_9_3' => make_ios_hash('Apple iPhone 4S A1387 9.3.5'),
        }

        hash
      end
    end

    # The hash of device capabilities, accessible by simple names
    DEVICE_HASH = create_hash
  end
end
