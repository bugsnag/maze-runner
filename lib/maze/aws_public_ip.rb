require 'bugsnag'

module Maze
  # Determines the public IP address and port when running on Buildkite with the Elastic CI Stack for AWS
  class AwsPublicIp
    attr_reader :host
    attr_reader :port

    def address
      "#{@ip}:#{@port}"
    end

    def initialize
      # This class is only relevant on Buildkite
      return unless ENV['BUILDKITE']

      @ip = determine_public_ip
      @port = determine_public_port Maze.config.port
    end

    # Determines the public IP address of the running AWS instance
    def determine_public_ip
      # 169.254.169.254 is the address of the AWS instance metadata service
      # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
      `curl --silent -XGET http://169.254.169.254/latest/meta-data/public-ipv4`
    end

    # Determines the external port of the running Docker container that's associated with the port given
    # @param local_port Local port to find the external port for
    def determine_public_port(local_port)
      port = 0
      count = 0
      max_attempts = 30
      invalid_response_retries = 0
      max_invalid_retries = 2

      # Give up after 30 seconds
      while port == 0 && count < max_attempts do
        hostname = ENV['HOSTNAME']
        command = "curl --silent -XGET --unix-socket /var/run/docker.sock http://localhost/containers/#{hostname}/json"
        result = Maze::Runner.run_command(command)
        if result[1] == 0
          begin
            json_string = result[0][0].strip
            json_result = JSON.parse(json_string)
            port = json_result['NetworkSettings']['Ports']["#{local_port}/tcp"][0]['HostPort']
          rescue NoMethodError => error
            if invalid_response_retries >= max_invalid_retries
              Bugsnag.notify error
              $logger.error "Public port response was invalid or incomplete: #{json_string}"
              $logger.error "This has occurred more than maximum allowed #{max_invalid_retries}, exiting port process"
              return 0
            else
              invalid_response_retries += 1
              $logger.warn "Public port response was invalid or incomplete: #{json_string}"
              $logger.warn "Attempting to acquire public port again, retry attempt: #{invalid_response_retries}"
            end
          rescue StandardError => error
            Bugsnag.notify error
            $logger.error "Unable to parse public port from: #{json_string}"
            return 0
          end
        end

        count += 1
        sleep 1 if port == 0 && count < max_attempts
      end
      $logger.error "Failed to determine public port within #{max_attempts} attempts" if port == 0 && count == max_attempts

      port
    end
  end
end
