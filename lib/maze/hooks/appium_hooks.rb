# Contains logic for the Cucumber hooks when in Appium mode
module Maze
  module Hooks
    # Hooks for Appium mode use
    class AppiumHooks < InternalHooks
      @client

      def before_all
        session_uuid = SecureRandom.uuid

        case Maze.config.farm
        when :bb
          @client = Maze::Client::Appium::BitBarClient.new session_uuid
        when :bs
          if ENV['USE_LEGACY_DRIVER']
            $logger.info 'Using the W3C Appium client'
            @client = Maze::Client::Appium::BrowserStackClient.new session_uuid
          else
            $logger.info 'Using the JSON-WP Appium client'
            @client = Maze::Client::Appium::BrowserStackJsonWPClient.new session_uuid
          end
        when :local
          @client = Maze::Client::Appium::LocalClient.new session_uuid
        end

        @client.prepare_session
        @client.start_session
        @client.log_session_info
      end

      # TODO: Refactor before and after method so that use of the driver is abstracted behind the relevant Appium client
      def before
        # Launch the app on macOS, if Appium is being used
        Maze.driver.get(Maze.config.app) if Maze.driver && Maze.config.os == 'macos'
      end

      def after
        if Maze.config.os == 'macos'
          # Close the app - without the sleep, launching the app for the next scenario intermittently fails
          system("killall -KILL #{Maze.config.app} && sleep 1")
        elsif [:bb].include? Maze.config.farm
          Maze.driver.terminate_app Maze.driver.app_id
          Maze.driver.activate_app Maze.driver.app_id
        else
          Maze.driver.terminate_app Maze.driver.app_id
          Maze.driver.activate_app Maze.driver.app_id
        end
      end

      def at_exit
        @client.stop_session
      end
    end
  end
end
