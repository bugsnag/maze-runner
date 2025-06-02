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

        def fail_driver(exception)
          Bugsnag.notify(exception)
          exception.instance_eval { def skip_bugsnag; true; end }
          @driver.fail_driver(exception.message)
        end
      end
    end
  end
end
