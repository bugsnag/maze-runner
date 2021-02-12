# frozen_string_literal: true

require 'json'
require 'shellwords'

module Maze
  module Aws
    # Interacts with the AWS SAM CLI to invoke Lambda functions
    # Note that the SAM CLI must be installed on the host machine as it does not
    # run in a Docker container! For this reason the "start-api" command is not
    # supported as it could easily cause port clashes and zombie processes
    class Sam
      class << self
        attr_reader :last_response, :last_exit_code

        # Invoke the given lambda with an optional event
        #
        # This happens synchronously so there is no need to wait for a response
        #
        # @param directory [String] The directory containing the lambda
        # @param lambda [String] The name of the lambda to invoke
        # @param event [String, nil] An optional event file to invoke with
        #
        # @return [void]
        def invoke(directory, lambda, event = nil)
          command = build_invoke_command(lambda, event)

          output, @last_exit_code = Maze::Runner.run_command("cd #{directory} && #{command}")

          @last_response = parse(output)
        end

        # Reset the last response and last exit code
        #
        # @return [void]
        def reset!
          @last_response = nil
          @last_exit_code = nil
        end

        private

        # Build the command to invoke the given lambda with the given event
        #
        # @param lambda [String] The name of the lambda to invoke
        # @param event [String, nil] An optional event file to invoke with
        #
        # @return [String]
        def build_invoke_command(lambda, event)
          command = "sam local invoke #{Shellwords.escape(lambda)}"
          command += " --event #{Shellwords.escape(event)}" unless event.nil?
          command += " --docker-network #{Shellwords.escape(ENV['NETWORK_NAME'])}" if ENV.key?('NETWORK_NAME')

          command
        end

        # The command output contains all stdout/stderr lines in an array. The
        # Lambda response is the last line of output as JSON. The response body is
        # also JSON, so we have to parse twice to get a Hash from the output
        #
        # @param output [Array<String>] The command's output as an array of lines
        #
        # @return [Hash]
        def parse(output)
          parsed_output = JSON.parse(output.last)

          # Error output has no "body" of additional JSON so we can stop here
          return parsed_output unless parsed_output.key?('body')

          parsed_output['body'] = JSON.parse(parsed_output['body'])

          parsed_output
        rescue JSON::ParserError
          raise <<~ERROR
            Unable to parse Lambda output!
            The likely cause is:
              > #{output.last.chomp}

            Full output:
              > #{output.map(&:chomp).join("\n  > ")}
          ERROR
        end
      end
    end
  end
end
