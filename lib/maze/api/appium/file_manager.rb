module Maze
  module Api
    module Appium
      # Provides operations for working with files during Appium runs.
      class FileManager < Maze::Api::Appium::Manager
        # Creates a file with the given contents on the device (using Appium).  The file will be located in the app's
        # documents directory for iOS. On Android, it will be /sdcard/Android/data/<app-id>/files unless
        # Maze.config.android_app_files_directory has been set.
        # @param contents [String] Content of the file to be written
        # @param filename [String] Name (with no path) of the file to be written on the device
        def write_app_file(contents, filename)
          if failed_driver?
            $logger.error 'Cannot write file to device - Appium driver failed.'
            return
          end

          path = case Maze::Helper.get_current_platform
                 when 'ios'
                   "@#{@driver.app_id}/Documents/#{filename}"
                 when 'android'
                   directory = Maze.config.android_app_files_directory || "/sdcard/Android/data/#{@driver.app_id}/files"
                   "#{directory}/#{filename}"
                 end

          $logger.trace "Pushing file to '#{path}' with contents: #{contents}"
          @driver.push_file(path, contents)
        end

        # Attempts to retrieve a given file from the device (using Appium).  The default location for the file will be
        # the app's documents directory for iOS. On Android, it will be /sdcard/Android/data/<app-id>/files unless
        # Maze.config.android_app_files_directory has been set.
        # @param filename [String] Name (with no path) of the file to be retrieved from the device
        # @param directory [String] Directory on the device where the file is located (optional)
        def read_app_file(filename, directory = nil)
          if failed_driver?
            $logger.error 'Cannot read file from device - Appium driver failed.'
            return
          end

          if directory
            path = directory
          else
            path = case Maze::Helper.get_current_platform
                  when 'ios'
                    "@#{@driver.app_id}/Documents/#{filename}"
                  when 'android'
                    dir = Maze.config.android_app_files_directory || "/sdcard/Android/data/#{@driver.app_id}/files"
                    "#{dir}/#{filename}"
                  end
          end

          $logger.trace "Attempting to read file from '#{path}'"
          file = @driver.pull_file(path)
        end
      end
    end
  end
end
