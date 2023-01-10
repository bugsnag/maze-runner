module Maze
  module Client
    module Selenium
      class BaseClient
        def start_session
          raise 'Method not implemented by this class'
        end

        def stop_session
          Maze.driver&.driver_quit
        end
      end
    end
  end
end
