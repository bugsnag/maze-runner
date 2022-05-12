# frozen_string_literal: true

module Maze
  # Appium capabilities for each target farm
  class Capabilities
    class << self
      # @param device_type [String] A key from @see BrowserStackDevices::DEVICE_HASH
      # @param local_id [String] unique key for the tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_browser_stack_device(device_type, local_id, appium_version, capabilities_option)
        capabilities = {
          'bstack:options' => {
            'local' => 'true',
            'localIdentifier' => local_id
          },
          'noReset' => 'true'
        }
        capabilities.deep_merge! BrowserStackDevices::DEVICE_HASH[device_type]
        capabilities.deep_merge! JSON.parse(capabilities_option)
        capabilities['bstack:options']['appiumVersion'] = appium_version unless appium_version.nil?
        capabilities
      end

      # @param browser_type [String] A key from @see browsers_bs.yml
      # @param local_id [String] unique key for the tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_browser_stack_browser(browser_type, local_id, capabilities_option)
        capabilities = {
          'bstack:options' => {
            'local' => 'true',
            'localIdentifier' => local_id,
            "os" => "Windows",
            "osVersion" => "8.1"
          }
        }
        browsers = YAML.safe_load(File.read("#{__dir__}/browsers_bs.yml"))
        capabilities.deep_merge! browsers[browser_type]
        capabilities.deep_merge! JSON.parse(capabilities_option)
        Selenium::WebDriver::Remote::Capabilities.new capabilities
      end

      # @param browser_type [String] A key from @see browsers_cbt.yml
      # @param local_id [String] unique key for the SB tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_cbt_browser(browser_type, local_id, capabilities_option)
        capabilities = Selenium::WebDriver::Remote::Capabilities.new
        capabilities['tunnel_name'] = local_id
        browsers = YAML.safe_load(File.read("#{__dir__}/browsers_cbt.yml"))
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

      def for_sauce_labs_device(device_name, os, os_version, tunnel_id, appium_version, capabilities_option)
        capabilities = {
          'noReset' => true,
          'deviceOrientation' => 'portrait',
          'tunnelIdentifier' => tunnel_id,
          'browserName' => '',
          'autoAcceptAlerts' => true,
          'sendKeyStrategy' => 'setValue',
          'waitForQuiescence' => false,
          'newCommandTimeout' => 0
        }
        capabilities['deviceName'] = device_name unless device_name.nil?
        capabilities['platformName'] = os unless os.nil?
        capabilities['platformVersion'] = os_version unless os_version.nil?
        capabilities.merge! JSON.parse(capabilities_option)
        capabilities['appiumVersion'] = appium_version unless appium_version.nil?
        capabilities
      end
    end
  end
end
