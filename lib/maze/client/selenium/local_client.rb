module Maze
  module Client
    module Selenium
      class LocalClient < BaseClient
        def prepare_session
          # Nothing to do
        end

        def start_session
          Maze.driver = Maze::Driver::Browser.new Maze.config.browser.to_sym
          Maze.driver.start_driver
        end

        def log_session_info
          # Nothing to do
        end

        def stop_session
          # No need to quit the local driver
        end
      end
    end
  end
end
