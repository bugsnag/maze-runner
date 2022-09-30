module Maze
  module Client
    module Appium
      class BrowserStackLegacyClient < BrowserStackClient
        def device_capabilities
          config = Maze.config
          capabilities = {
            'app' => config.app,
            'browserstack.console' => 'errors',
            'browserstack.localIdentifier' => @session_uuid,
            'browserstack.local' => 'true',
            'deviceOrientation' => 'portrait',
            'noReset' => 'true'
          }
          capabilities.deep_merge! Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH[config.device]
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities['browserstack.appium_version'] = config.appium_version unless config.appium_version.nil?
          capabilities
        end
      end
    end
  end
end
