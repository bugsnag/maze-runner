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
        $logger.debug "Appium after hook"

        manager = Maze::Api::Appium::AppManager.new
        if Maze.config.os == 'macos'
          # Close the app - without the sleep launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb, :bs, :local].include? Maze.config.farm
          close_fallback = Maze.config.appium_version && Maze.config.appium_version.to_f < 2.0
          begin
            manager.terminate(!close_fallback)
          rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::InvalidSessionIdError
            if close_fallback
              $logger.warn 'terminate_app failed, using the slower but more forceful close_app instead'
              manager.close
            else
              $logger.warn 'terminate_app failed, future errors may occur if the application did not close properly'
            end
          end

          # Reset the server before relaunching the app to ensure that test fixtures cannot fetch
          # commands from the previous scenario (in idempotent mode).
          Maze::Server.reset!
          manager.activate
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
    end
  end
end
