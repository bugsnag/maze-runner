# Appium capabilities for each target farm
class Capabilities
  class << self
    def for_browser_stack(device_type, local_id)
      capabilities = {
        'browserstack.console': 'errors',
        'browserstack.localIdentifier': local_id,
        'browserstack.local': 'true',
        'browserstack.networkLogs': 'true',
      }
      capabilities.merge! Devices::DEVICE_HASH[device_type]
    end

    def for_local
      {
        'platformName': 'Android',
        'automationName': 'UiAutomator2',
        'autoAcceptAlerts': 'true',
        'app': 'features/fixtures/mazerunner/build/outputs/apk/release/mazerunner-release.apk'
      }
    end
  end
end
