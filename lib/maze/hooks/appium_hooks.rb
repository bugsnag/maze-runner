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
          if Maze.config.legacy_driver?
            $logger.info 'Using the Legacy (JWP) Appium client'
            @client = Maze::Client::Appium::BrowserStackLegacyClient.new session_uuid
          else
            $logger.info 'Using the W3C Appium client'
            @client = Maze::Client::Appium::BrowserStackClient.new session_uuid
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
        elsif [:bb, :bs, :local].include? Maze.config.farm
          # appium_lib 12 says that reset is deprecated and activate_app/terminate_app should be used
          # instead.  However, they do not clear out app data, which we need between scenarios.
          # install_app/remove_app might also be an option to consider.
          Maze.driver.reset
        end
      end

      def at_exit
        @client.stop_session
      end
    end
  end
end
