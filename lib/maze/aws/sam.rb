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
          if ENV.key?('VOLUME_BASEDIR')
            basedir = "#{ENV['VOLUME_BASEDIR']}/#{directory}"
          else
            basedir = nil
          end

          command = build_invoke_command(lambda, event, basedir)

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

        def current_ip
          return "host.docker.internal" if OS.mac?
        
          ip_addr = `ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\\.){3}[0-9]*' | grep -v '127.0.0.1'`
          ip_list = /((?:[0-9]*\.){3}[0-9]*)/.match(ip_addr)
          ip_list.captures.first
        end

        # Build the command to invoke the given lambda with the given event
        #
        # @param lambda [String] The name of the lambda to invoke
        # @param event [String, nil] An optional event file to invoke with
        #
        # @return [String]
        def build_invoke_command(lambda, event, basedir = nil)
          command = "sam local invoke #{Shellwords.escape(lambda)}"
          command += " --event #{Shellwords.escape(event)}" unless event.nil?
          command += " --container-host #{current_ip)}"
          command += " --docker-network #{Shellwords.escape(ENV['NETWORK_NAME'])}" if ENV.key?('NETWORK_NAME')
          command += " --docker-volume-basedir #{basedir}" unless basedir.nil?
          pp command
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
            raise <<~ERROR
              Unable to parse Lambda output!
              The likely cause is:
                > #{output.last.chomp}

              Full output:
                > #{output.map(&:chomp).join("\n  > ")}
            ERROR
          end

          # Attempt to parse the last line of output as this is where a JSON
          # response would be. It's possible for a Lambda to output nothing,
          # e.g. if it forcefully exited, so we allow JSON parse failures here
          begin
            parsed_output = JSON.parse(output.last)
          rescue JSON::ParserError
            return {}
          end

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
