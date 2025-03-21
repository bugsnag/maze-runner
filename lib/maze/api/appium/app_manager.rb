require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with the app.
      class AppManager < Maze::Api::Appium::Manager

        # Activates the app
        # @returns [Boolean] Whether the app was successfully launched
        def activate
          if failed_driver?
            $logger.error 'Cannot activate the app - Appium driver failed.'
            return false
          end

          @driver.activate_app(@driver.app_id)
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Terminates the app
        # @returns [Boolean] Whether the app was successfully closed
        def terminate
          if failed_driver?
            $logger.error 'Cannot terminate the app - Appium driver failed.'
            return false
          end

          @driver.terminate_app(@driver.app_id)
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Launches the app (legacy method).
        # @returns [Boolean] Whether the app was successfully launched
        def launch
          if failed_driver?
            $logger.error 'Cannot launch the app - Appium driver failed.'
            return false
          end

          @driver.launch_app
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Closes the app (legacy method).
        # @returns [Boolean] Whether the app was successfully closed
        def close
          if failed_driver?
            $logger.error 'Cannot close the app - Appium driver failed.'
            return false
          end

          @driver.close_app
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Gets the app state.
        # @returns [Symbol, nil] The app state, such as :not_running, :running_in_foreground, :running_in_background - of nil if the driver has failed.
        def state
          if failed_driver?
            $logger.error('Cannot get the app state - Appium driver failed.')
            return nil
          end

          @driver.app_state(@driver.app_id)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end
      end
    end
  end
end
