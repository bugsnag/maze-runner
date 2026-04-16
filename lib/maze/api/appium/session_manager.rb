require 'selenium-webdriver'
require_relative '../../helper'
require_relative './manager'

module Maze
  module Api
    module Appium
      # Provides operations for working with Appium session capabilities.
      class SessionManager < Maze::Api::Appium::Manager

        # Gets the session capabilities.
        # @return [Hash, nil] The session capabilities, or nil if the driver has failed.
        def session_capabilities
          # Check if driver is nil first
          if @driver.nil?
            $logger&.error('Cannot get session capabilities - Appium driver is nil.')
            return nil
          end

          if failed_driver?
            $logger&.error('Cannot get session capabilities - Appium driver failed.')
            return nil
          end

          @driver.session_capabilities
          
        rescue Selenium::WebDriver::Error::WebDriverError => e
          $logger&.error("❌ WebDriver Error - Failed to get session capabilities: #{e.message}")
          fail_driver(e) if @driver
          raise e
          
        rescue Socket::ResolutionError => e
          $logger&.error("❌ Network Error - Cannot reach Appium server: #{e.message}")
          $logger&.error("   This usually means: BrowserStack/Appium server is unreachable")
          fail_driver(e) if @driver
          raise e
          
        rescue Errno::ECONNREFUSED => e
          $logger&.error("❌ Connection Refused - Appium server rejected connection: #{e.message}")
          fail_driver(e) if @driver
          raise e
          
        rescue Timeout::Error => e
          $logger&.error("❌ Timeout - Appium server took too long to respond: #{e.message}")
          fail_driver(e) if @driver
          raise e
          
        rescue => e
          $logger&.error("❌ Unexpected Error - Failed to get session capabilities: #{e.class} - #{e.message}")
          fail_driver(e) if @driver
          raise e
        end

        # Gets a specific capability value from the session.
        # @param capability_name [String, Symbol] The name of the capability to retrieve
        # @return [Object, nil] The capability value, or nil if not found or driver has failed.
        def capability(capability_name)
          capabilities = session_capabilities
          
          if capabilities.nil?
            $logger&.warn("⚠️  Capabilities are nil - cannot retrieve '#{capability_name}'")
            return nil
          end
          
          value = capabilities[capability_name.to_s]
          value
          
        rescue Socket::ResolutionError => e
          $logger&.error("❌ Network Error while getting capability '#{capability_name}': #{e.message}")
          return nil
          
        rescue Errno::ECONNREFUSED => e
          $logger&.error("❌ Connection Refused while getting capability '#{capability_name}': #{e.message}")
          return nil
          
        rescue Timeout::Error => e
          $logger&.error("❌ Timeout while getting capability '#{capability_name}': #{e.message}")
          return nil
          
        rescue => e
          $logger&.error("❌ Error getting capability '#{capability_name}': #{e.class} - #{e.message}")
          return nil
        end
      end
    end
  end
end