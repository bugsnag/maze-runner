require 'json'
require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with the app.
      class DeviceManager < Maze::Api::Appium::Manager

        # Unlocks the device.
        # @returns [Boolean] Success status
        def unlock
          if failed_driver?
            $logger.error 'Cannot unlock the device - Appium driver failed.'
            return false
          end

          @driver.unlock
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Presses the Back button.
        # @returns [Boolean] Success status
        def back
          if failed_driver?
            $logger.error 'Cannot press the Back button - Appium driver failed.'
            return false
          end

          @driver.back
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Gets logs from the device.
        # @param log_type [String] The type pf log to get as recognised by Appium, such as 'syslog'
        #
        # @returns [Array, nil] Array of Selenium::WebDriver::LogEntry, or nil if the driver has failed
        def get_log(log_type)
          if failed_driver?
            $logger.error 'Cannot get logs - Appium driver failed.'
            return nil
          end

          @driver.get_log(log_type)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Sets the rotation of the device.
        # @param orientation [Symbol] The orientation to set the device to, :portrait or :landscape
        # @returns [Boolean] Success status
        def set_rotation(orientation)
          if failed_driver?
            $logger.error 'Cannot set the device rotation - Appium driver failed.'
            return false
          end

          @driver.set_rotation(orientation)
          true
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end

        # Gets the device info, in JSON format
        # @returns [String, nil] Device info or nil
        def info
          if failed_driver?
            $logger.error 'Cannot get the device info - Appium driver failed.'
            return nil
          end

          JSON.generate(@driver.device_info)
        rescue Selenium::WebDriver::Error::ServerError => e
          # Assume the remote appium session has stopped, so crash out of the session
          fail_driver(e.message)
          raise e
        end
      end
    end
  end
end
