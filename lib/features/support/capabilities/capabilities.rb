# frozen_string_literal: true

require_relative './devices'

# Appium capabilities for each target farm
class Capabilities
  class << self
    # @param device_type [String] A key from @see Devices::DEVICE_HASH
    # @param local_id [String] unique key for the tunnel instance
    def for_browser_stack(device_type, local_id)
      capabilities = {
        'browserstack.console' => 'errors',
        'browserstack.localIdentifier' => local_id,
        'browserstack.local' => 'true',
        'browserstack.networkLogs' => 'true'
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
    end

    # Constructs Appium capabilities for running on a local Android or iOS device.
    # @param platform [String] 'ios' or 'android'
    # @param team_id [String] Apple Team Id, for iOS only
    # @param udid [String] device UDID, for iOS only
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
                         'deviceName' => udid,
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
