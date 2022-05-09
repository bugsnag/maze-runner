# frozen_string_literal: true

require 'socket'

module Maze
  # Receives and terminates network connections without reading any data
  class TerminatingServer
    CONTINUE_RESPONSE = "HTTP/1.1 100 CONTINUE\n\r"
    BAD_REQUEST_RESPONSE = "HTTP/1.1 400 BAD REQUEST\n\r"

    class << self

      # Starts the socket accept loop in a separate thread
      def start
        # Only run a single server thread
        return if running?

        attempts = 0
        loop do

          @thread = Thread.new do
            # Reset the received count
            @received_requests = 0

            Socket.tcp_server_loop(Maze.config.null_port) {|socket, _client_addrinfo|
              $logger.info 'Terminating server received request'
              @received_requests += 1
              headers = receive_headers(socket)

              body_length = headers['Content-Length']
              receive_data(socket, body_length) unless body_length.nil?

              end_connection(socket)
            }
          rescue StandardError => e
            $logger.warn "Terminating server error: #{e.message}"
          end

          break if running?

          # Bail out after 3 attempts
          attempts += 1
          raise 'Too many failed attempts to start terminating server' if attempts == 3

          # Failed to start - sleep before retrying
          $logger.info 'Retrying in 3 seconds'
          sleep 1
        end
      end

      # The maximum string length to be received before disconnecting
      #
      # @return [Integer] The string length, defaults to 1MB
      def max_received_size
        @max_received_size ||= 1048576
      end

      # Set the maximum string length to be received before disconnecting
      #
      # @param new_max_size [Integer] The new maximum size
      def max_received_size=(new_max_size)
        @max_received_size = new_max_size
      end

      # The response string sent to a connected client
      #
      # @return [String] The response string, defaults to "400/BAD REQUEST"
      def response
        @response ||= BAD_REQUEST_RESPONSE
      end

      # Set the response string to an arbitrary value
      #
      # @param new_response [String] The new response
      def response=(new_response)
        @response = new_response
      end

      # Resets the response string to "400/BAD REQUEST" and the read size to 1MB
      def reset_elements
        @response = BAD_REQUEST_RESPONSE
        @max_received_size = 1048576
      end

      # Whether the server thread is running
      #
      # @return [Boolean] If the server is running
      def running?
        @thread&.alive?
      end

      # Outputs the amount of times the server has received a connection on the last run
      def received_request_count
        @received_requests ||= 0
      end

      # Stops the socket accept loop if alive
      def stop
        @thread&.kill if @thread&.alive?
        @thread = nil
      end

      private

      def receive_headers(socket)
        headers = {}
        while (request = socket.gets) && (request.chomp.length > 0)
          key, val = request.chomp.split(': ')
          headers[key] = val
          $logger.debug "Received #{headers.size} headers"
        end
        headers
      end

      def receive_data(socket, body_length)
        read_length = body_length.to_i < max_received_size ? body_length.to_i : max_received_size
        $logger.info "Reading #{read_length} bytes"
        socket.read(read_length)
      end

      def end_connection(socket)
        $logger.info "Responding with: #{response}"
        # Unlikely to be used, but replicates pipeline response
        socket.print response
        socket.close
      end
    end
  end
end
