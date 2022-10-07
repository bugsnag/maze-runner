# frozen_string_literal: true

module Maze
  module Hooks
    # Registers an exit hook that will process the reason for an early exit and provide a suitable error code.
    # Error codes and their meanings are as follows:
    #
    #
    class ErrorCodeHook

      # Error classes that indicate the selenium/appium drivers have  
      DRIVER_ERRORS = [
        Maze::Error::AppiumElementNotFoundError,

        Selenium::WebDriver::Error::NoSuchElementError,
        Selenium::WebDriver::Error::StaleElementReferenceError,
        Selenium::WebDriver::Error::TimeoutError,
        Selenium::WebDriver::Error::UnknownError,
        Selenium::WebDriver::Error::WebDriverError
      ].freeze

      class << self

        attr_accessor :exit_code

        def register_exit_code_hook
          return if @registered
          at_exit do
            override_exit_code = nil

            case
            when test_errors.intersection(DRIVER_ERRORS).size > 0
              override_exit_code = 3
            end

            # Check if a specific error code has been registered elsewhere
            override_exit_code = @exit_code if @exit_code

            # If an override code is specified, use it, otherwise we'll use the native exit code
            exit(override_exit_code) unless override_exit_code.nil?
          end
          @registered = true
        end

        def add_test_error(error)
          test_errors << error
        end

        def test_errors
          @test_errors ||= []
        end
      end
    end
  end
end
