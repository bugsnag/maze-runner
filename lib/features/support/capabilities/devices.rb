# Provides a source of capabilities used to run tests against specific BrowserStack devices
# noinspection RubyStringKeysInHashInspection
class Devices

  # The hash of device capabilities, accessible by simple names
  ANDROID_10_0 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Pixel 4',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '10.0'
  }.freeze
  ANDROID_9_0 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Pixel 3',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '9.0'
  }.freeze
  ANDROID_8_1 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Samsung Galaxy Note 9',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '8.1'
  }.freeze
  ANDROID_8_0 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Pixel 2',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '8.0'
  }.freeze
  ANDROID_7_1 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Pixel',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '7.1'
  }.freeze
  ANDROID_6_0 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Nexus 6',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '6.0'
  }.freeze
  ANDROID_5_0 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Nexus 6',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '5.0'
  }.freeze
  ANDROID_4_4 = {
    'autoGrantPermissions' => 'true',
    'device' => 'Google Nexus 5',
    'platformName' => 'Android',
    'os' => 'android',
    'os_version' => '4.4'
  }.freeze
  IOS_13 = {
      'device' => 'iPhone 8',
      'platformName' => 'iOS',
      'os' => 'ios',
      'os_version' => '13'
  }.freeze
  IOS_12 = {
    'device' => 'iPhone 8',
    'platformName' => 'iOS',
    'os' => 'ios',
    'os_version' => '12'
  }.freeze
  IOS_11 = {
    'device' => 'iPhone 8',
    'platformName' => 'iOS',
    'os' => 'ios',
    'os_version' => '11'
  }.freeze
  IOS_10 = {
    'device' => 'iPhone 7',
    'platformName' => 'iOS',
    'os' => 'ios',
    'os_version' => '10'
  }.freeze
  DEVICE_HASH = {
    'ANDROID_10_0' => ANDROID_10_0,
    'ANDROID_9_0' => ANDROID_9_0,
    'ANDROID_8_1' => ANDROID_8_1,
    'ANDROID_8_0' => ANDROID_8_0,
    'ANDROID_7_1' => ANDROID_7_1,
    'ANDROID_6_0' => ANDROID_6_0,
    'ANDROID_4_4' => ANDROID_4_4,
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
