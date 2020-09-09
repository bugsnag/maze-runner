# Provides a source of capabilities used to run tests against specific BrowserStack devices
# noinspection RubyStringKeysInHashInspection
class Devices

  class << self
    def make_android_hash(device, version)
      {
        'device' => device,
        'os_version' => version,
        'autoGrantPermissions' => 'true',
        'platformName' => 'Android',
        'os' => 'android'
      }.freeze
    end

    def add_android(device, version, hash)
      name = device.upcase.gsub ' ', '_'
      new_version = version.gsub '.', '_'
      key = "ANDROID_#{new_version}_#{name}"
      hash[key] = make_android_hash device, version
    end

    def make_ios_hash(device, version)
      {
        'device' => device,
        'os_version' => version,
        'platformName' => 'iOS',
        'os' => 'ios'
      }.freeze
    end

    def create_hash
      hash = {
        # Classic, non-specific devices for each Android version
        'ANDROID_10_0' => make_android_hash('Google Pixel 4', '10.0'),
        'ANDROID_9_0' => make_android_hash('Google Pixel 3', '9.0'),
        'ANDROID_8_1' => make_android_hash('Samsung Galaxy Note 9', '8.1'),
        'ANDROID_8_0' => make_android_hash('Google Pixel 2', '8.0'),
        'ANDROID_7_1' => make_android_hash('Google Pixel', '7.1'),
        'ANDROID_6_0' => make_android_hash('Google Nexus 6', '6.0'),
        'ANDROID_5_0' => make_android_hash('Google Nexus 6', '5.0'),
        'ANDROID_4_4' => make_android_hash('Google Nexus 5', '4.4'),

        # iOS devices
        'IOS_14' => make_ios_hash('iPhone 11', '14'),
        'IOS_13' => make_ios_hash('iPhone 8', '13'),
        'IOS_12' => make_ios_hash('iPhone 8', '12'),
        'IOS_11' => make_ios_hash('iPhone 8', '11'),
        'IOS_10' => make_ios_hash('iPhone 7', '10')
      }
      # Deprecated entries
      hash['ANDROID_9'] = hash['ANDROID_9_0']
      hash['ANDROID_8'] = hash['ANDROID_8_0']
      hash['ANDROID_7'] = hash['ANDROID_7_1']
      hash['ANDROID_6'] = hash['ANDROID_6_0']
      hash['ANDROID_5'] = hash['ANDROID_5_0']
      hash['ANDROID_4'] = hash['ANDROID_4_4']

      # Specific Android devices
      add_android 'Google Pixel 4', '11.0', hash
      add_android 'Samsung Galaxy Note 9', '8.1', hash
      add_android 'Samsung Galaxy J7 Prime', '8.1', hash
      add_android 'Samsung Galaxy Tab S4', '8.1', hash
      add_android 'Google Pixel', '8.0', hash
      add_android 'Google Pixel 2', '8.0', hash
      add_android 'Samsung Galaxy S9', '8.0', hash
      add_android 'Samsung Galaxy S9 Plus', '8.0', hash
      add_android 'Samsung Galaxy Tab S3', '8.0', hash
      add_android 'Motorola Moto X 2nd Gen', '6.0', hash
      add_android 'Google Nexus 6', '6.0', hash
      add_android 'Samsung Galaxy S7', '6.0', hash

      hash
    end
  end

  # The hash of device capabilities, accessible by simple names
  DEVICE_HASH = create_hash
end
