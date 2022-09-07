# frozen_string_literal: true

module Maze
  # Appium capabilities for each target farm
  class Capabilities
    class << self
      # @param device_type [String]
      def for_bitbar_device(bitbar_api_key, device_type, platform, platform_version, capabilities_option)
        capabilities = {
          'disabledAnimations' => 'true',
          'noReset' => 'true',
          'bitbar:options' => {
            'apiKey' => bitbar_api_key,
            'testrun' => "#{platform} #{platform_version}",
            'findDevice' => false,
            'testTimeout' => 7200,
          }
        }
        capabilities.deep_merge! BitBarDevices.get_device(device_type, platform, platform_version, bitbar_api_key)
        capabilities.deep_merge! JSON.parse(capabilities_option)

        capabilities
      end



      # selenium jsonwp
      #
      # capabilities = Selenium::WebDriver::Remote::Capabilities.new
      # capabilities['platform'] = 'Linux'
      # capabilities['osVersion'] = '18.04'
      # capabilities['browserName'] = 'firefox'
      # capabilities['version'] = '104'
      # capabilities['resolution'] = '2560x1920'
      # capabilities['bitbar_apiKey'] = '<insert your BitBar API key here>'

# selenium w3c

      # capabilities = Selenium::WebDriver::Remote::Capabilities.new
      # 'platformName' => 'Linux',
      # capabilities['browserName'] = 'firefox'
      # capabilities['browserVersion'] = '104'
      # capabilities['bitbar:options'] = {
      #   'apiKey' = '<insert your BitBar API key here>'
      # 'resolution' = '2560x1920'
      # 'osVersion' = '18.04'
      # }

      # appium jsonwp
      #
      # desired_capabilities_cloud = {
      #   'bitbar_apiKey' => '<insert your BitBar API key here>',
      #   'bitbar_device' => 'Asus Google Nexus 7 2013 6.0.1',
      #   'platformName' => 'Android',
      #   'deviceName' => 'Android Phone',
      #   'automationName' => 'Appium',
      # }

      # browserstack (w3c)
      #
      # 'platformName' => 'android',
      #   'platformVersion' => version,
      #   'deviceName' => device,
      #   'autoGrantPermissions' => 'true',
      #   'bstack:options' => {
      #     "appiumVersion" => appium_version,
      #   },



# @param browser_type [String] A key from @see browsers_bb.yml
      # @param local_id [String] unique key for the SB tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_bitbar_browsers(browser_type, api_key, local_id, capabilities_option)
        capabilities = Selenium::WebDriver::Remote::Capabilities.new
        capabilities['bitbar_apiKey'] = api_key
        browsers = YAML.safe_load(File.read("#{__dir__}/browsers_bb.yml"))
        capabilities.merge! browsers[browser_type]
        capabilities.merge! JSON.parse(capabilities_option)
        capabilities
      end

      # Constructs Appium capabilities for running on a local Android or iOS device.
      # @param platform [String] 'ios' or 'android'
      # @param capabilities_option [String] extra capabilities provided on the command line
      # @param team_id [String] Apple Team Id, for iOS only
      # @param udid [String] device UDID, for iOS only
      # noinspection RubyStringKeysInHashInspection
      def for_local(platform, capabilities_option, team_id = nil, udid = nil)
        capabilities = case platform.downcase
                       when 'android'
                         {
                           'platformName' => 'Android',
                           'automationName' => 'UiAutomator2',
                           'autoGrantPermissions' => 'true',
                           'noReset' => 'true'
                         }
                       when 'ios'
                         {
                           'platformName' => 'iOS',
                           'automationName' => 'XCUITest',
                           'deviceName' => udid,
                           'xcodeOrgId' => team_id,
                           'xcodeSigningId' => 'iPhone Developer',
                           'udid' => udid,
                           'noReset' => 'true',
                           'waitForQuiescence' => false,
                           'newCommandTimeout' => 0
                         }
                       when 'macos'
                         {
                           'platformName' => 'Mac'
                         }
                       else
                         raise "Unsupported platform: #{platform}"
                       end
        common = {
          'os' => platform,
          'autoAcceptAlerts': 'true'
        }
        capabilities.merge! common
        capabilities.merge! JSON.parse(capabilities_option)
      end
    end
  end
end
