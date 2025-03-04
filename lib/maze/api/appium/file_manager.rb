require_relative '../../helper'
require_relative './manager'

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
        # @return [Boolean] Whether the file was successfully written to the device
        def write_app_file(contents, filename)
          if failed_driver?
            $logger.error 'Cannot write file to device - Appium driver failed.'
            return false
          end

          path = case Maze::Helper.get_current_platform
                 when 'ios'
                   "@#{@driver.app_id}/Documents/#{filename}"
                 when 'android'
                   directory = Maze.config.android_app_files_directory || "/sdcard/Android/data/#{@driver.app_id}/files"
                   "#{directory}/#{filename}"
                 else
                   raise 'write_app_file is not supported on this platform'
                 end

          $logger.trace "Pushing file to '#{path}' with contents: #{contents}"
          @driver.push_file(path, contents)
          true
        rescue Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Error writing file to device: #{e.message}"
          false
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Attempts to retrieve a given file from the device (using Appium).  The default location for the file will be
        # the app's documents directory for iOS. On Android, it will be /sdcard/Android/data/<app-id>/files unless
        # Maze.config.android_app_files_directory has been set.
        # @param filename [String] Name (with no path) of the file to be retrieved from the device
        # @param directory [String] Directory on the device where the file is located (optional)
        # @return [String, nil] The content of the file read, or nil
        def read_app_file(filename, directory = nil)
          if failed_driver?
            $logger.error 'Cannot read file from device - Appium driver failed.'
            return nil
          end

          if directory
            path = "#{directory}/#{filename}"
          else
            path = case Maze::Helper.get_current_platform
                  when 'ios'
                    "@#{@driver.app_id}/Documents/#{filename}"
                  when 'android'
                    dir = Maze.config.android_app_files_directory || "/sdcard/Android/data/#{@driver.app_id}/files"
                    "#{dir}/#{filename}"
                  else
                    raise 'read_app_file is not supported on this platform'
                  end
          end

          $logger.trace "Attempting to read file from '#{path}'"
          @driver.pull_file(path)
        rescue Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Error reading file from device: #{e.message}"
          nil
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end
      end
    end
  end
end
