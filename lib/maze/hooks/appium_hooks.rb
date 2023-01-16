# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      @client

      def before_all
        @client = Maze::Client::Appium.start
      end

      def before(scenario)
        # Launch the app on macOS, if Appium is being used
        Maze.driver.get(Maze.config.app) if Maze.driver && Maze.config.os == 'macos'
      end

      def after(scenario)

        if Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb, :bs, :local].include? Maze.config.farm
          write_device_logs(scenario) if scenario.failed?

          # appium_lib 12 says that reset is deprecated and activate_app/terminate_app should be used
          # instead.  However, they do not clear out app data, which we need between scenarios.
          # install_app/remove_app might also be an option to consider.
          Maze.driver.reset
        end
      end

      def at_exit
        @client.stop_session
      end

      private

      # Pulls the device logs using Appium and writes them to file in the maze_output folder
      def write_device_logs(scenario)
        log_name = case Maze::Helper.get_current_platform
                   when 'android'
                     'logcat'
                   when 'ios'
                     'syslog'
                   end
        logs = Maze.driver.get_log(log_name)

        Maze::MazeOutput.new(scenario).write_device_logs(logs)
      end
    end
  end
end
