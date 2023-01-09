# Contains logic for the Cucumber hooks when in Browser mode
module Maze
  module Hooks
    # Hooks for Browser mode use
    class BrowserHooks < InternalHooks
      def before_all
        @client = Maze::Client::Selenium.start
      end

      def at_exit
        @client.stop_session
      end
    end
  end
end
