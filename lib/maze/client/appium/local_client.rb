module Maze
  module Client
    module Appium
      class LocalClient < BaseClient
        def prepare_session
          # Attempt to start the local appium server
          appium_uri = URI(config.appium_server_url)
          Maze::AppiumServer.start(address: appium_uri.host, port: appium_uri.port) if config.start_appium
        end

        def device_capabilities
          config = Maze.config
          capabilities = Maze::Capabilities.for_local config.os,
                                                      config.capabilities_option,
                                                      config.apple_team_id,
                                                      config.device_id
          capabilities
        end

        def log_session_info
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
