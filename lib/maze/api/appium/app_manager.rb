require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with the app.
      class AppManager < Maze::Api::Appium::Manager

        # Launches the app.
        # @returns [Boolean] Whether the app was successfully launched
        def launch
          $logger.info 'SKW Launch the app'

          if failed_driver?
            $logger.error 'Cannot launch the app - Appium driver failed.'
            return false
          end

          @driver.launch_app
          true
        rescue Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Error launching the app: #{e.message}"
          false
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver
          raise e
        end

        # Closes the app.
        # @returns [Boolean] Whether the app was successfully closed
        def close
          $logger.info 'SKW Close the app'

          if failed_driver?
            $logger.error 'Cannot close the app - Appium driver failed.'
            return false
          end

          @driver.close_app
          true
        rescue Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Error closing the app: #{e.message}"
          false
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver
          raise e
        end
      end
    end
  end
end
