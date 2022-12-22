# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  module Hooks
    # Hooks for Browser mode use
    class BrowserHooks < InternalHooks
      def before_all
        session_uuid = SecureRandom.uuid

        case Maze.config.farm
        when :bb
          @client = Maze::Client::Selenium::BitBarClient.new session_uuid
        when :bs
          @client = Maze::Client::Selenium::BrowserStackClient.new session_uuid
        when :local
          @client = Maze::Client::Selenium::LocalClient.new session_uuid
        end

        @client.prepare_session
        @client.start_session
        @client.log_session_info
      end

      def at_exit
        @client.stop_session
      end
    end
  end
end
