# frozen_string_literal: true

module Maze
  # Provides a source of capabilities used to run tests against specific BrowserStack devices
  # noinspection RubyStringKeysInHashInspection
  class BitBarDevices
    APPIUM_1_9_1 = '1.9.1'
    APPIUM_1_15_0 = '1.15.0'
    APPIUM_1_20_2 = '1.20.2'

    class << self
      def make_android_hash(device, appium_version = nil)
        hash = {
          'platformName' => 'Android',
          'bitbar_device' => device,
          'bitbar_target' => 'android'
        }
        hash['bitbar_appiumVersion'] = appium_version if appium_version
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
          'bitbar_target' => 'ios'
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

          # iOS devices
          'IOS_14' => make_ios_hash('Apple iPad 8 A2270 14.0.1'),
        }

        hash
      end
    end

    # The hash of device capabilities, accessible by simple names
    DEVICE_HASH = create_hash
  end
end
