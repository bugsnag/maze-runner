# frozen_string_literal: true

module Maze
  module Client
    module Appium
      # Provides a source of capabilities used to run tests against specific BrowserStack devices
      # noinspection RubyStringKeysInHashInspection
      class BrowserStackDevices
        class << self

          def list_devices(os)
            puts "BrowserStack #{os} devices available:"
            devices = DEVICE_HASH.dup
            devices.select { |key, device|
              device['platformName'].eql?(os)
            }.map { |key, device|
              new_device = device.dup
              new_device['key'] = key
              new_device
            }.sort { |dev_1, dev_2|
              dev_1['platformVersion'].to_f <=> dev_2['platformVersion'].to_f
            }.each{ |device|
              puts '------------------------------'
              puts "Device key: #{device['key']}"
              puts "Device:     #{device['deviceName']}"
              puts "OS:         #{device['platformName']}"
              puts "OS version: #{device['platformVersion']}"
            }
          end

          def make_android_hash(device, version)
            hash = {
              'platformName' => 'android',
              'platformVersion' => version,
              'deviceName' => device,
              'autoGrantPermissions' => 'true',
            }
            hash.freeze
          end

          def add_android(device, version, hash)
            # Key format is "ANDROID_<version>_<device>", with:
            # - dots in versions and all spaces replaced with underscores
            # - device made upper case
            name = device.upcase.gsub ' ', '_'
            new_version = version.gsub '.', '_'
            key = "ANDROID_#{new_version}_#{name}"
            hash[key] = make_android_hash device, version
          end

          def make_ios_hash(device, version)
            {
              'platformName' => 'ios',
              'platformVersion' => version,
              'deviceName' => device
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
            hash[key] = make_ios_hash device, version
          end

          def create_hash
            hash = {
              # Classic, non-specific devices for each Android version
              'ANDROID_13' => make_android_hash('Google Pixel 6 Pro', '13.0'),
              'ANDROID_12' => make_android_hash('Google Pixel 5', '12.0'),
              'ANDROID_11' => make_android_hash('Google Pixel 4', '11.0'),
              'ANDROID_10' => make_android_hash('Google Pixel 4', '10.0'),
              'ANDROID_9' => make_android_hash('Google Pixel 3', '9.0'),
              'ANDROID_8' => make_android_hash('Samsung Galaxy Note 9', '8.1'),
              'ANDROID_7' => make_android_hash('Google Pixel', '7.1'),

              # iOS devices
              'IOS_17' => make_ios_hash('iPhone 15', '17'),
              'IOS_16' => make_ios_hash('iPhone 14', '16'),
              'IOS_15' => make_ios_hash('iPhone 11 Pro', '15'),
              'IOS_14' => make_ios_hash('iPhone 11', '14'),
              'IOS_13' => make_ios_hash('iPhone 8', '13'),
              'IOS_12' => make_ios_hash('iPhone 8', '12'),
              'IOS_11' => make_ios_hash('iPhone 8', '11'),
              'IOS_10' => make_ios_hash('iPhone 7', '10')
            }

            # Specific Android devices
            add_android 'Google Pixel 4', '11.0', hash                        # ANDROID_11_0_GOOGLE_PIXEL_4

            add_android 'Xiaomi Redmi Note 9', '10.0', hash                   # ANDROID_10_0_XIAOMI_REDMI_NOTE_9
            add_android 'Samsung Galaxy Note 20', '10.0', hash                # ANDROID_10_0_SAMSUNG_GALAXY_NOTE_20
            add_android 'Motorola Moto G9 Play', '10.0', hash                 # ANDROID_10_0_MOTOROLA_MOTO_G9_PLAY
            add_android 'OnePlus 8', '10.0', hash                             # ANDROID_10_0_ONEPLUS_8

            add_android 'Google Pixel 2', '9.0', hash                         # ANDROID_9_0_GOOGLE_PIXEL_2
            add_android 'Samsung Galaxy Note 9', '8.1', hash                  # ANDROID_8_1_SAMSUNG_GALAXY_NOTE_9
            add_android 'Samsung Galaxy J7 Prime', '8.1', hash                # ANDROID_8_1_SAMSUNG_GALAXY_J7_PRIME
            add_android 'Samsung Galaxy Tab S4', '8.1', hash                  # ANDROID_8_1_SAMSUNG_GALAXY_TAB_S4
            add_android 'Samsung Galaxy Tab S3', '8.0', hash                  # ANDROID_8_0_SAMSUNG_GALAXY_TAB_S3
            add_android 'Google Pixel 2', '8.0', hash                         # ANDROID_8_0_GOOGLE_PIXEL_2
            add_android 'Samsung Galaxy S9', '8.0', hash                      # ANDROID_8_0_SAMSUNG_GALAXY_S9
            add_android 'Samsung Galaxy S9 Plus', '8.0', hash                 # ANDROID_8_0_SAMSUNG_GALAXY_S9_PLUS

            add_android 'Samsung Galaxy A8', '7.1', hash                      # ANDROID_7_1_SAMSUNG_GALAXY_A8
            add_android 'Samsung Galaxy Note 8', '7.1', hash                  # ANDROID_7_1_SAMSUNG_GALAXY_NOTE_8
            add_android 'Samsung Galaxy S8', '7.0', hash                      # ANDROID_7_0_SAMSUNG_GALAXY_S8

            # Specific iOS devices
            add_ios 'iPhone 15 Pro Max', '17.0', hash                         # IOS_17_0_IPHONE_15_PRO_MAX
            add_ios 'iPhone 15 Pro', '17.0', hash                             # IOS_17_0_IPHONE_15_PRO
            add_ios 'iPhone 15', '17.0', hash                                 # IOS_17_0_IPHONE_15

            add_ios 'iPhone 14 Plus', '16.0', hash                            # IOS_16_0_IPHONE_14_PLUS
            add_ios 'iPhone 14 Pro', '16.0', hash                             # IOS_16_0_IPHONE_14_PRO
            add_ios 'iPhone 14 Pro Max', '16.0', hash                         # IOS_16_0_IPHONE_14_PRO_MAX

            add_ios 'iPhone 8 Plus', '11.0', hash                             # IOS_11_0_IPHONE_8_PLUS
            add_ios 'iPhone X', '11.0', hash                                  # IOS_11_0_IPHONE_X
            add_ios 'iPhone SE', '11.0', hash                                 # IOS_11_0_IPHONE_SE
            add_ios 'iPhone 6', '11.0', hash                                  # IOS_11_0_IPHONE_6
            add_ios 'iPhone 6S', '11.0', hash                                 # IOS_11_0_IPHONE_6S
            add_ios 'iPhone 6S Plus', '11.0', hash                            # IOS_11_0_IPHONE_6S_PLUS
            add_ios 'iPad 5th', '11.0', hash                                  # IOS_11_0_IPAD_5TH
            add_ios 'iPad Mini 4', '11.0', hash                               # IOS_11_0_IPAD_MINI_4
            add_ios 'iPad Pro 9.7 2016', '11.0', hash                         # IOS_11_0_IPAD_PRO_9_7_2016
            add_ios 'iPad 6th', '11.0', hash                                  # IOS_11_0_IPAD_6TH
            add_ios 'iPad Pro 12.9', '11.0', hash                             # IOS_11_0_IPAD_PRO_12_9

            hash
          end
        end

        # The hash of device capabilities, accessible by simple names
        DEVICE_HASH = create_hash
      end
    end
  end
end
