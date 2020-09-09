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

    def make_ios_hash(device, version)
      {
        'device' => device,
        'os_version' => version,
        'platformName' => 'iOS',
        'os' => 'ios'
      }.freeze
    end
  end

  # The hash of device capabilities, accessible by simple names
  ANDROID_11_0_PIXEL_4 = Devices.make_android_hash 'Google Pixel 4', '11.0'
  ANDROID_11_0 = ANDROID_11_0_PIXEL_4
  ANDROID_10_0 = Devices.make_android_hash 'Google Pixel 4', '10.0'
  ANDROID_9_0 = Devices.make_android_hash 'Google Pixel 3', '9.0'
  ANDROID_8_1_GALAXY_NOTE_9 = Devices.make_android_hash 'Samsung Galaxy Note 9', '8.1'
  ANDROID_8_1_GALAXY_J7_PRIME = Devices.make_android_hash 'Samsung Galaxy J7 Prime', '8.1'
  ANDROID_8_1_GALAXY_TAB_S4 = Devices.make_android_hash 'Samsung Galaxy Tab S4', '8.1'
  ANDROID_8_1 = ANDROID_8_1_GALAXY_NOTE_9
  ANDROID_8_0_PIXEL = Devices.make_android_hash 'Google Pixel', '8.0'
  ANDROID_8_0_PIXEL_2 = Devices.make_android_hash 'Google Pixel 2', '8.0'
  ANDROID_8_0_GALAXY_S9 = Devices.make_android_hash 'Samsung Galaxy S9', '8.0'
  ANDROID_8_0_GALAXY_S9_PLUS = Devices.make_android_hash 'Samsung Galaxy S9 Plus', '8.0'
  ANDROID_8_0_GALAXY_TAB_S3 = Devices.make_android_hash 'Samsung Galaxy Tab S3', '8.0'
  ANDROID_8_0 = ANDROID_8_0_PIXEL_2
  ANDROID_7_1 = Devices.make_android_hash 'Google Pixel', '7.1'
  ANDROID_6_0_MOTO_X_2ND_GEN = Devices.make_android_hash 'Motorola Moto X 2nd Gen', '6.0'
  ANDROID_6_0_NEXUS_6 = Devices.make_android_hash 'Google Nexus 6', '6.0'
  ANDROID_6_0_GALAXY_S7 = Devices.make_android_hash 'Samsung Galaxy S7', '6.0'
  ANDROID_6_0 = ANDROID_6_0_NEXUS_6
  ANDROID_5_0 = Devices.make_android_hash 'Google Nexus 6', '5.0'
  ANDROID_4_4 = Devices.make_android_hash 'Google Nexus 5', '4.4'
  IOS_14 = make_ios_hash('iPhone 11', '14')
  IOS_13 = make_ios_hash('iPhone 8', '13')
  IOS_12 = make_ios_hash('iPhone 8', '12')
  IOS_11 = make_ios_hash('iPhone 8', '11')
  IOS_10 = make_ios_hash('iPhone 7', '10')
  DEVICE_HASH = {
    'ANDROID_11_0' => ANDROID_11_0,
    'ANDROID_11_0_PIXEL_4' => ANDROID_11_0_PIXEL_4,
    'ANDROID_10_0' => ANDROID_10_0,
    'ANDROID_9_0' => ANDROID_9_0,
    'ANDROID_8_1' => ANDROID_8_1,
    'ANDROID_8_1_GALAXY_J7_PRIME' => ANDROID_8_1_GALAXY_J7_PRIME,
    'ANDROID_8_1_GALAXY_NOTE_9' => ANDROID_8_1_GALAXY_NOTE_9,
    'ANDROID_8_1_GALAXY_TAB_S4' => ANDROID_8_1_GALAXY_TAB_S4,
    'ANDROID_8_0' => ANDROID_8_0,
    'ANDROID_8_0_GALAXY_S9' => ANDROID_8_0_GALAXY_S9,
    'ANDROID_8_0_GALAXY_S9_PLUS' => ANDROID_8_0_GALAXY_S9_PLUS,
    'ANDROID_8_0_GALAXY_TAB_S3' => ANDROID_8_0_GALAXY_TAB_S3,
    'ANDROID_8_0_PIXEL' => ANDROID_8_0_PIXEL,
    'ANDROID_8_0_PIXEL_2' => ANDROID_8_0_PIXEL_2,
    'ANDROID_7_1' => ANDROID_7_1,
    'ANDROID_6_0' => ANDROID_6_0,
    'ANDROID_6_0_NEXUS_6' => ANDROID_6_0_NEXUS_6,
    'ANDROID_6_0_GALAXY_S7' => ANDROID_6_0_GALAXY_S7,
    'ANDROID_6_0_MOTO_X_2ND_GEN' => ANDROID_6_0_MOTO_X_2ND_GEN,
    'ANDROID_4_4' => ANDROID_4_4,
    'IOS_14' => IOS_14,
    'IOS_13' => IOS_13,
    'IOS_12' => IOS_12,
    'IOS_11' => IOS_11,
    'IOS_10' => IOS_10,
    # Deprecated entries
    'ANDROID_9' => ANDROID_9_0,
    'ANDROID_8' => ANDROID_8_0,
    'ANDROID_7' => ANDROID_7_1,
    'ANDROID_6' => ANDROID_6_0,
    'ANDROID_5' => ANDROID_5_0,
    'ANDROID_4' => ANDROID_4_4
  }.freeze
end
