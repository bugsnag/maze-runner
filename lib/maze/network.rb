# frozen_string_literal: true

require 'socket'

module Maze
  # Sets the maximum number of times Maze runner will ping to see if a port is open, defaulting to 100
  MAX_MAZE_CONNECT_ATTEMPTS = ENV.fetch('MAX_MAZE_CONNECT_ATTEMPTS', 100).to_i

  # Provides network utility functionality
  class Network
    class << self
      # Repeatedly pings a port to see if the host is ready for a connection.
      # The maximum amount of attempts is determined by the MAX_MAZE_CONNECT_ATTEMPTS variable.
      #
      # @param host [String] The name of the host to connect to
      # @param port [String] The port to attempt to connect to
      #
      # @raise [StandardError] When the port is not available for a connection
      def wait_for_port(host, port)
        attempts = 0
        up = false
        until (attempts >= MAX_MAZE_CONNECT_ATTEMPTS) || up
          attempts += 1
          up = port_open?(host, port)
          sleep 0.1 unless up
        end
        raise "Port not ready in time!" unless up
      end

      # Attempts to connect to a port, timing out after a time.
      #
      # @param host [String] The name of the host to connect to
      # @param port [String] The port to attempt to connect to
      # @param seconds [Float] Optional. The length of time to wait before timing out.
      def port_open?(host, port, seconds=0.1)
        Timeout::timeout(seconds) do
          begin
            TCPSocket.new(host, port).close
            true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
            false
          end
        end
      rescue Timeout::Error
        false
      end
    end
  end
end
