module Maze
  module Client
    module Appium
      class LocalClient < BaseClient
        def prepare_session
          # Attempt to start the local appium server
          appium_uri = URI(Maze.config.appium_server_url)
          Maze::AppiumServer.start(address: appium_uri.host, port: appium_uri.port.to_s) if Maze.config.start_appium
        end

        def device_capabilities
          config = Maze.config
          platform = Maze::Helper.get_current_platform
          capabilities = case platform
                         when 'android'
                           {
                             'platformName' => 'Android',
                             'automationName' => 'UiAutomator2',
                             'autoGrantPermissions' => 'true',
                             'noReset' => 'true',
                             'app' => config.app,
                             'os' => platform,
                             'autoAcceptAlerts': 'true'
                           }
                         when 'ios'
                           {
                             'platformName' => 'iOS',
                             'automationName' => 'XCUITest',
                             'deviceName' => config.device_id,
                             'xcodeOrgId' => config.apple_team_id,
                             'xcodeSigningId' => 'iPhone Developer',
                             'udid' => config.device_id,
                             'noReset' => 'true',
                             'waitForQuiescence' => false,
                             'newCommandTimeout' => 0,
                             'app' => config.app,
                             'os' => platform,
                             'autoAcceptAlerts': 'true'
                           }
                         when 'macos'
                           {
                             'platformName' => 'mac',
                             'automationName' => 'mac2',
                             'appium:options' => {
                               'appPath' => config.app,
                               'bundleId' => config.app_bundle_id
                             }
                           }
                         else
                           raise "Unsupported platform: #{config.os}"
                         end
          capabilities.merge! JSON.parse(config.capabilities_option)

          $logger.info '******'
          $logger.info capabilities

          capabilities
        end

        def log_run_intro
          # Nothing to do
        end

        def log_run_outro
          # Nothing to do
        end

        def stop_session
          super
          # Acquire and output the logs for the current session
          Maze::Runner.run_command("log show --predicate '(process == \"#{Maze.config.app}\")' --style syslog --start '#{Maze.start_time}' > #{Maze.config.app}.log")
        end
      end
    end
  end
end
