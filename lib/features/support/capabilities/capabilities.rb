# frozen_string_literal: true

# Appium capabilities for each target farm
class Capabilities
  class << self
    # @param device_type [String] A key from @see Devices::DEVICE_HASH
    # @param local_id [String] unique key for the tunnel instance
    # @param capabilties_option [String] extra capabilities provided on the command line
    def for_browser_stack(device_type, local_id, appium_version, capabilties_option)
      capabilities = {
        'browserstack.console' => 'errors',
        'browserstack.localIdentifier' => local_id,
        'browserstack.local' => 'true',
        'browserstack.networkLogs' => 'true'
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
      capabilities.merge! JSON.parse(capabilties_option)
      capabilities['browserstack.appium_version'] = appium_version unless appium_version.nil?
      capabilities
    end

    # Constructs Appium capabilities for running on a local Android or iOS device.
    # @param platform [String] 'ios' or 'android'
    # @param capabilties_option [String] extra capabilities provided on the command line
    # @param team_id [String] Apple Team Id, for iOS only
    # @param udid [String] device UDID, for iOS only
    # noinspection RubyStringKeysInHashInspection
    def for_local(platform, capabilties_option, team_id = nil, udid = nil)
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
      capabilities.merge! JSON.parse(capabilties_option)
    end
  end
end
