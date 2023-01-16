module Maze
  module Api
    module Appium
      # Provides operations for working with files during Appium runs.
      class FileManager
        # param driver
        def initialize
          @driver = Maze.driver
        end

        # Pushes a file into view of the app (the app's Document/files for for iOS/Android)
        # @param source_path [String] Filename, including path, of the file to be pushed
        # @param destination_filename [String] Name (with no path) of the file to be written on the device
        def push_app_file(source_path, destination_filename)
          destination_path = case Maze::Helper.get_current_platform
                             when 'ios'
                               "@#{@driver.app_id}/Documents/#{destination_filename}"
                             when 'android'
                               "/data/user/0/#{@driver.app_id}/files/#{destination_filename}"
                             end
          $logger.debug "Pushing file '#{source_path}' to '#{destination_path}'"
          @driver.push_file(destination_path, File.read(source_path))
        end
      end
    end
  end
end
