# frozen_string_literal: true

require_relative './devices'

# Appium capabilities for each target farm
class Capabilities
  class << self
    def for_browser_stack(device_type)
      raise "Device type '#{device_type}' not known" unless Devices::DEVICE_HASH.keys.include? device_type

      capabilities = {
        'browserstack.console': 'errors',
        'browserstack.localIdentifier': 'local_id',
        'browserstack.local': 'true',
        'browserstack.networkLogs': 'true'
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
    end

    def for_local(platform)
      capabilities = if platform == :android
                       {
                         'platformName': 'Android',
                         'automationName': 'UiAutomator2'
                       }
                     elsif platform == :ios
                       {
                           'platformName': 'Android',
                           'automationName': 'UiAutomator2'
                       }
                     end
      common = {
        'autoAcceptAlerts': 'true',
        'app': 'features/fixtures/mazerunner/build/outputs/apk/release/mazerunner-release.apk'
      }
      capabilities.merge! common
    end
  end
end
