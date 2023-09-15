# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      @client

      def before_all
        Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_started')
        @client = Maze::Client::Appium.start
      end

      def before(scenario)
        @client.start_scenario
      end

      def after(scenario)

        if Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb, :bs, :local].include? Maze.config.farm
          write_device_logs(scenario) if scenario.failed?

          # TODO: PLAT-10300 - Review our general approach to resetting the app between scenarios
          re = Regexp.new('^1\.1[56]\.\d$')
          if re.match? Maze.config.appium_version
            Maze.driver.close_app
            Maze.driver.launch_app
          else
            Maze.driver.reset
          end
        end
      end

      def after_all
        @client&.log_run_outro
        if $success
          Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_succeeded')
        else
          Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_failed')
        end
      end

      def at_exit
        if @client
          $logger.info 'Stopping the Appium session'
          @client.stop_session
        end
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
