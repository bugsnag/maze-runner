module Maze
  module Client
    module Appium
      class BrowserStackLegacyClient < BrowserStackClient
        def device_capabilities
          config = Maze.config
          capabilities = {
            'app' => config.app,
            'browserstack.console' => 'errors',
            'deviceOrientation' => 'portrait',
            'noReset' => 'true'
          }
          device_caps = Maze::Client::Appium::BrowserStackDevices::DEVICE_HASH[config.device]
          capabilities.deep_merge! device_caps
          capabilities.deep_merge! JSON.parse(config.capabilities_option)
          capabilities.merge! project_name_capabilities
          capabilities['browserstack.appium_version'] = config.appium_version unless config.appium_version.nil?
          unless device_caps['platformName'] == 'android' && device_caps['platformVersion'].to_i <= 6
            capabilities['disableAnimations'] = 'true'
          end
          if Maze.config.start_tunnel
            capabilities['browserstack.localIdentifier'] = @session_uuid
            capabilities['browserstack.local'] = 'true'
          end

          capabilities
        end
      end
    end
  end
end
