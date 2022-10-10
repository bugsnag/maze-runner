# frozen_string_literal: true

module Maze
  module Hooks
    # Registers an exit hook that will process the reason for an early exit and provide a suitable error code.
    # Error code sets and specific code meanings are as follows:
    #   1*: An error has occurred within browser or device drivers:
    #     10: An unknown error has occurred
    #     11: An expected UI element was missing
    #     12: A UI element was missing at time of interaction
    #     13: A command sent to the remote server timed out
    #     14: An element was present but did not accept interaction
    #   2*: Errors relating to potential network, test server, or payload issues
    #     21: Expected payload(s) was not received
    #     22: A command was not read by the test fixture
    class ErrorCodeHook
      class << self

        attr_accessor :exit_code
        attr_accessor :last_test_error_class

        def register_exit_code_hook
          return if @registered
          at_exit do
            override_exit_code = nil

            maze_errors = Maze::Error::ERROR_CODES
            if maze_errors.include?(last_test_error_class)
              override_exit_code = maze_errors[last_test_error_class][:error_code]
            end

            # Check if a specific error code has been registered elsewhere
            override_exit_code = @exit_code if @exit_code

            # If an override code is specified, use it, otherwise we'll use the native exit code
            exit(override_exit_code) unless override_exit_code.nil?
          end
          @registered = true
        end
      end
    end
  end
end
