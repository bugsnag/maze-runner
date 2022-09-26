# frozen_string_literal: true

module Maze
  # Appium capabilities for each target farm
  class Capabilities
    class << self

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
