# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      def before_all
        session_uuid = SecureRandom.uuid
        Maze::Client::Appium::BaseClient.prepare_session session_uuid
        Maze::Client::Appium::BaseClient.start_session session_uuid
        Maze::Client::Appium::BaseClient.log_session_info
      end

      def before
        # Launch the app on macOS, if Appium is being used
        Maze.driver.get(Maze.config.app) if Maze.driver && Maze.config.os == 'macos'
      end

      def after
        if Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb].include? Maze.config.farm
          Maze.driver.launch_app
        else
          Maze.driver.terminate_app Maze.driver.app_id
          Maze.driver.activate_app Maze.driver.app_id
        end
      end

      def at_exit
        # Stop the Appium session and server
        Maze.driver.driver_quit
        Maze::AppiumServer.stop if Maze::AppiumServer.running

        if Maze.config.farm == :local && Maze.config.os == 'macos'
          # Acquire and output the logs for the current session
          Maze::Runner.run_command("log show --predicate '(process == \"#{Maze.config.app}\")' --style syslog --start '#{Maze.start_time}' > #{Maze.config.app}.log")
        elsif Maze.config.farm == :bs
          Maze::Farm::BrowserStack::Utils.stop_local_tunnel
        elsif Maze.config.farm == :bb
          Maze::SmartBearUtils.stop_local_tunnel
          Maze::BitBarUtils.release_account(Maze.config.tms_uri) if ENV['BUILDKITE']
        end
      end
    end
  end
end
