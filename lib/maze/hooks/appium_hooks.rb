# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      @client

      def before_all
        Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_started')
        @client = Maze::Client::Appium.start
      rescue => error
        # Notify and re-raise for Cucumber to handle
        Bugsnag.notify error
        raise
      end

      def before(scenario)
        @client.start_scenario
      rescue => error
        # Notify and re-raise for Cucumber to handle
        Bugsnag.notify error
        raise
      end

      def after(scenario)

        if Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb, :bs, :local].include? Maze.config.farm
          write_device_logs(scenario) if scenario.failed?

          # Reset the server to ensure that test fixtures cannot fetch
          # commands from the previous scenario (in idempotent mode).
          begin
            Maze.driver.terminate_app Maze.driver.app_id
          rescue Selenium::WebDriver::Error::UnknownError
            if Maze.config.appium_version && Maze.config.appium_version.to_f < 2.0
              $logger.warn 'terminate_app failed, using the slower but more forceful close_app instead'
              Maze.driver.close_app
            else
              $logger.warn 'terminate_app failed, future errors may occur if the application did not close remotely'
            end
          end
          Maze::Server.reset!
          Maze.driver.activate_app Maze.driver.app_id
        end
      rescue => error
        # Notify and re-raise for Cucumber to handle
        Bugsnag.notify error
        raise
      end

      def after_all
        if $success
          Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_succeeded')
        else
          Maze::Plugins::DatadogMetricsPlugin.send_increment('appium.test_failed')
        end
      rescue => error
        # Notify and re-raise for Cucumber to handle
        Bugsnag.notify error
        raise
      end

      def at_exit
        if @client
          @client.log_run_outro
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
