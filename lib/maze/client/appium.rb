module Maze
  module Client
    module Appium
      def self.start
        client_class =
          case Maze.config.farm
          when :bb then BitBarClient
          when :bs then BrowserStackClient
          when :local then LocalClient
          end

        client_class.new.tap(&:start_session)
      end
    end
  end
end
