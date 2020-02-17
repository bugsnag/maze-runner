# Provides a source of capabilities used to run tests against specific BrowserStack devices
#noinspection RubyStringKeysInHashInspection
class Devices
  # The hash of device capabilities, accessible by simple names
  DEVICE_HASH = {
      'ANDROID_10' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Pixel 4',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '10.0',
          'browserstack.appium_version' => '1.15.0'
      },
      'ANDROID_9' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Pixel 3',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '9.0'
      },
      'ANDROID_8_1' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Samsung Galaxy Note 9',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '8.1'
      },
      'ANDROID_8_0' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Pixel 2',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '8.0'
      },
      'ANDROID_7_1' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Pixel',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '7.1'
      },
      'ANDROID_6' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Nexus 6',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '6.0'
      },
      'ANDROID_5' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Nexus 6',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '5.0'
      },
      'ANDROID_4_4' => {
          'autoGrantPermissions' => 'true',
          'device' => 'Google Nexus 5',
          'platformName' => 'Android',
          'os' => 'android',
          'os_version' => '4.4'
      },
      'IOS_12' => {
          'device' => 'iPhone 8',
          'platformName' => 'iOS',
          'os' => 'ios',
          'os_version' => '12'
      },
      'IOS_11' => {
          'device' => 'iPhone 8',
          'platformName' => 'iOS',
          'os' => 'ios',
          'os_version' => '11'
      },
      'IOS_10' => {
          'device' => 'iPhone 7',
          'platformName' => 'iOS',
          'os' => 'ios',
          'os_version' => '10'
      }
  }
end
