module Maze
  module Client
    module Selenium
      class BaseClient
        def initialize(session_uuid)
          @session_uuid = session_uuid
        end

        def prepare_session
          raise 'Method not implemented by this class'
        end

        def start_session
          raise 'Method not implemented by this class'
        end

        def log_session_info
          raise 'Method not implemented by this class'
        end

        def stop_session
          Maze.driver&.driver_quit
        end
      end
    end
  end
end
