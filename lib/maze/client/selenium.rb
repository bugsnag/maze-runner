module Maze
  module Client
    module Selenium
      def self.start(session_uuid)
        client_class =
          case Maze.config.farm
          when :bb then BitBarClient
          when :bs then BrowserStackClient
          when :local then LocalClient
          end

        client_class.new(session_uuid).tap(&:start_session)
      end
    end
  end
end
