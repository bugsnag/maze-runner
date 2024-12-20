module Maze
  module Api
    module Appium
      # Base class for all Appium managers.
      class Manager
        def initialize
          @driver = Maze.driver
        end

        def failed_driver?
          @driver.failed?
        end

        def fail_driver
          @driver.fail_driver
        end
      end
    end
  end
end
