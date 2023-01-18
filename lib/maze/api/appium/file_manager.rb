module Maze
  module Api
    module Appium
      # Provides operations for working with files during Appium runs.
      class FileManager
        # param driver
        def initialize
          @driver = Maze.driver
        end

        # Creates a file with the given contents on the device (using Appium).  The file will be located in the app's
        # Documents directory for iOS and /sdcard/Android/data/<app-id>/ for Android.
        # @param contents [String] Content of the file to be written
        # @param filename [String] Name (with no path) of the file to be written on the device
        def write_app_file(contents, filename)
          path = case Maze::Helper.get_current_platform
                 when 'ios'
                   "@#{@driver.app_id}/Documents/#{filename}"
                 when 'android'
                   "/sdcard/Android/data/#{@driver.app_id}/#{filename}"
                 end

          $logger.debug "Pushing file to '#{path}' with contents: #{contents}"
          @driver.push_file(path, contents)
        end
      end
    end
  end
end
