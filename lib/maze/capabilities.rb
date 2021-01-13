# frozen_string_literal: true

module Maze
  # Appium capabilities for each target farm
  class Capabilities
    class << self
      # @param device_type [String] A key from @see Devices::DEVICE_HASH
      # @param local_id [String] unique key for the tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_browser_stack_device(device_type, local_id, appium_version, capabilities_option)
        capabilities = {
          'browserstack.console' => 'errors',
          'browserstack.localIdentifier' => local_id,
          'browserstack.local' => 'true'
        }
        capabilities.merge! Devices::DEVICE_HASH[device_type]
        capabilities.merge! JSON.parse(capabilities_option)
        capabilities['browserstack.appium_version'] = appium_version unless appium_version.nil?
        capabilities
      end

      # @param browser_type [String] A key from @see browsers.yml
      # @param local_id [String] unique key for the tunnel instance
      # @param capabilities_option [String] extra capabilities provided on the command line
      def for_browser_stack_browser(browser_type, local_id, capabilities_option)
        capabilities = Selenium::WebDriver::Remote::Capabilities.new
        capabilities['browserstack.local'] = 'true'
        capabilities['browserstack.localIdentifier'] = local_id
        capabilities['browserstack.console'] = 'errors'
        browsers = YAML.safe_load(File.read("#{__dir__}/browsers.yml"))
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
        capabilities = if platform.downcase == 'android'
                         {
                           'platformName' => 'Android',
                           'automationName' => 'UiAutomator2',
                           'autoGrantPermissions' => 'true'
                         }
                       elsif platform.downcase == 'ios'
                         {
                           'platformName' => 'iOS',
                           'automationName' => 'XCUITest',
                           'deviceName' => udid,
                           'xcodeOrgId' => team_id,
                           'xcodeSigningId' => 'iPhone Developer',
                           'udid' => udid
                         }
                       elsif platform.downcase == 'macos'
                         {
                           'platformName' => 'Mac'
                         }
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
