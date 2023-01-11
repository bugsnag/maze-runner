module Maze
  # Determines the public IP address and port when running on Buildkite with the Elastic CI Stack for AWS
  class AwsPublicIp
    attr_reader :address

    def initialize
      # This class is only relevant on Buildkite
      return unless ENV['BUILDKITE']

      ip = determine_public_ip
      port = determine_public_port

      @address = "#{ip}:#{port}"
    end

    # Determines the public IP address of the running AWS instance
    def determine_public_ip
      `curl --silent -XGET http://169.254.169.254/latest/meta-data/public-ipv4`
    end

    # Determines the external port of the running Docker container that's associated with the port of the mock server
    def determine_public_port
      port = 0
      count = 0
      max_attempts = 30

      # Give up after 30 seconds
      while port == 0 && count < max_attempts do
        hostname = ENV['HOSTNAME']
        command = "curl --silent -XGET --unix-socket /var/run/docker.sock http://localhost/containers/#{hostname}/json"
        result = Maze::Runner.run_command(command)
        if result[1] == 0
          begin
            json_string = result[0][0].strip
            json_result = JSON.parse(json_string)
            port = json_result['NetworkSettings']['Ports']["#{Maze.config.port}/tcp"][0]['HostPort']
          rescue StandardError
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
