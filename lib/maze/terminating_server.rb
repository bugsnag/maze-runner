# frozen_string_literal: true

require 'socket'

module Maze
  # Receives and terminates network connections without reading any data
  class TerminatingServer

    class << self

      # Starts the socket accept loop in a separate thread
      def start
        attempts = 0
        loop do

          @thread = Thread.new do
            Socket.tcp_server_loop(Maze.config.null_port) {|socket, _client_addrinfo|
              $logger.info 'Terminating server received request'
              $logger.info "Responding with: #{response}"
              # Unlikely to be used, but replicates pipeline response
              socket.print response
              socket.close
            }
          rescue StandardError => e
            $logger.warn "Failed to start terminating server: #{e.message}"
          end

          break if running?

          # Bail out after 3 attempts
          attempts += 1
          raise 'Too many failed attempts to start terminating server' if attempts == 3

          # Failed to start - sleep before retrying
          $logger.info 'Retrying in 3 seconds'
          sleep 3
        end
      end

      # The response string sent to a connected client
      #
      # @return [String] The response string, defaults to "400/BAD REQUEST"
      def response
        @response ||= 'HTTP/1.1 400/BAD REQUEST\r\n'
      end

      # Set the response string to an arbitrary value
      #
      # @param new_response [String] The new response
      def response=(new_response)
        @response = new_response
      end

      # Resets the response string to "400/BAD REQUEST"
      def reset_response
        @response = 'HTTP/1.1 400/BAD REQUEST\r\n'
      end

      # Whether the server thread is running
      #
      # @return [Boolean] If the server is running
      def running?
        @thread&.alive?
      end

      # Stops the socket accept loop if alive
      def stop
        @thread&.kill if @thread&.alive?
        @thread = nil
      end
    end
  end
end