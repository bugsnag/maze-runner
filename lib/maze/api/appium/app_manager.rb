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
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to activate app: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Terminates the app.  If terminate fails then clients may wish to ty the legacy close method, so an option
        # is provided to not fail the Appium driver.
        # @param fail_driver [Boolean] Whether to fail the Appium driver if the app cannot be terminated
        # @returns [Boolean] Whether the app was successfully closed
        def terminate(fail_driver = true)
          if failed_driver?
            $logger.error 'Cannot terminate the app - Appium driver failed.'
            return false
          end

          @driver.terminate_app(@driver.app_id)
          true
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to terminate app: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message) if fail_driver
          raise e
        end

        # Instructs Appium to background the app
        # @param seconds [Integers] The number of seconds to background the app for, or -1 for indefinitely
        # @returns [Boolean] Whether the instruction to Appium was successfully made
        def background(seconds = -1)
          if failed_driver?
            $logger.error 'Cannot background the app - Appium driver failed.'
            return false
          end

          @driver.background_app(seconds)
          true
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to background app: #{e.message}"
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
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to launch app: #{e.message}"
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
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to close app: #{e.message}"
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
        rescue Selenium::WebDriver::Error::ServerError, Selenium::WebDriver::Error::UnknownError => e
          $logger.error "Failed to get app state: #{e.message}"
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end
      end
    end
  end
end
