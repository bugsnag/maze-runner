# frozen_string_literal: true

require_relative './configuration'

# Glues the various parts of MazeRunner together that need to be accessed globally,
# providing an alternative to the proliferation of global variables or singletons.
class MazeRunner
  class << self
    attr_accessor :driver
    def configuration
      @configuration ||= Configuration.new
    end

    def setup_cucumber_hooks
      AfterConfiguration do |config|
        BrowserStackUtils.upload_app(bs_username, bs_access_key, app_location)
        MazeRunner.driver = ResilientAppiumDriver.new(bs_username, bs_access_key, bs_local_id, bs_device, app_location)
        MazeRunner.driver.start_driver unless MazeRunner.configuration.appium_session_isolation
      end

      After do
        MazeRunner.driver.reset_with_timeout unless MazeRunner.configuration.appium_session_isolation
      end

      at_exit do
        MazeRunner.driver.driver_quit unless MazeRunner.configuration.appium_session_isolation
      end
    end

  end
end

