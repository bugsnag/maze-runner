# frozen_string_literal: true

require_relative './devices'

# Appium capabilities for each target farm
class Capabilities
  class << self
    def for_browser_stack(device_type)
      raise "Device type '#{device_type}' not known on BrowserStack" \
        unless Devices::DEVICE_HASH.keys.include? device_type

      capabilities = {
        'browserstack.console': 'errors',
        'browserstack.localIdentifier': 'local_id',
        'browserstack.local': 'true',
        'browserstack.networkLogs': 'true'
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
    end

    def for_local(platform)
      capabilities = if platform.downcase == 'android'
                       {
                         'platformName': 'Android',
                         'automationName': 'UiAutomator2',
                         'autoGrantPermissions' => 'true',
                         'os': 'android'
                       }
                     elsif platform.downcase == 'ios'
                       {
                         'platformName': 'iOS',
                         'automationName': 'XCUITest',
                         'os': 'ios'
                       }
                     end
      common = {
        'autoAcceptAlerts': 'true'
      }
      capabilities.merge! common
    end
  end
end
