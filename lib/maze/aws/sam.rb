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

          unless valid?(output)
            message = <<-WARNING
              The lambda function did not successfully complete.
              This may be expected and a normal result of the test execution.
              The listed cause is:
                > #{output.last.chomp}

              Full output:
                > #{output.map(&:chomp).join("\n  > ")}
            WARNING
            $logger.warn message
          end

          # Attempt to parse response line of the output.
          # We can assume that the output is the last line present that is JSON parsable
          response_lines = output.find_all { |line| /^{.*}$/.match(line.strip) }
          response_line = response_lines.last
          parsed_output = response_line.nil? ? {} : JSON.parse(response_line)

          # Error output has no "body" of additional JSON so we can stop here
          return parsed_output unless parsed_output.key?('body')

          # The body is _usually_ JSON but doesn't have to be. We attempt to
          # parse it anyway because it allows us to assert against it easily,
          # but if this fails then it may just be in another format, e.g. HTML
          begin
            parsed_output['body'] = JSON.parse(parsed_output['body'])
          rescue JSON::ParserError
            # Ignore
          end

          parsed_output
        end

        # Check if the output looks valid. There should be a "END" marker with a
        # request ID if the lambda invocation completed successfully
        #
        # @param output [Array<String>] The command's output as an array of lines
        #
        # @return [Boolean]
        def valid?(output)
          output.any? { |line| line =~ /^END RequestId:/ }
        end
      end
    end
  end
end
