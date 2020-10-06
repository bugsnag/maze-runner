# frozen_string_literal: true

require_relative './devices'

# Appium capabilities for each target farm
class Capabilities
  class << self
    # @param [String] device_type A key from @see Devices::DEVICE_HASH
    def for_browser_stack(device_type)
      capabilities = {
        'browserstack.console' => 'errors',
        'browserstack.localIdentifier' => 'local_id',
        'browserstack.local' => 'true',
        'browserstack.networkLogs' => 'true'
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
    end

    # Constructs Appium capabilities for running on a local Android or iOS device.
    # @param [String] platform 'ios' or 'android'
    # @param [String] team_id Apple Team Id, for iOS only
    # @param [String] udid device UDID, for iOS only
    # noinspection RubyStringKeysInHashInspection
    def for_local(platform, team_id = nil, udid = nil)
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
                         'deviceName' => 'a8aa3799a6d598da496f3fb1a30fad1c3f79e03f',
                         'xcodeOrgId' => team_id,
                         'xcodeSigningId' => 'iPhone Developer',
                         'udid' => udid
                       }
                     end
      common = {
        'os' => platform,
        'autoAcceptAlerts': 'true'
      }
      capabilities.merge! common
    end
  end
end
