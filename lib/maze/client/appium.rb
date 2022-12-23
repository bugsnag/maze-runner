module Maze
  module Client
    module Appium
      def self.start(session_uuid)
        client_class =
          case Maze.config.farm
          when :bb then BitBarClient
          when :bs
            if Maze.config.legacy_driver?
              $logger.info 'Using the Legacy (JWP) Appium client'
              BrowserStackLegacyClient
            else
              $logger.info 'Using the W3C Appium client'
              BrowserStackClient
            end
          when :local then LocalClient
          end

        client_class.new(session_uuid).tap(&:start_session)
      end
    end
  end
end
