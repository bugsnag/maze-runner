# frozen_string_literal: true

require 'json'
require 'webrick'
require_relative './servlet'
require_relative './logger'
require_relative './request_list'

module Maze
  # Receives and stores requests through a WEBrick HTTPServer
  class Server

    # There are some constraints on the port from driving remote browsers on BrowserStack.
    # E.g. the ports/ranges that Safari will access on "localhost" urls are restricted to the following:
    #   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999 [ from https://stackoverflow.com/a/28678652 ]
    PORT = 9339

    class << self
      # Allows overwriting of the server status code
      attr_writer :status_code

      # Dictates if the status code should be reset after used
      attr_writer :reset_status_code

      # The intended HTTP status code on a successful request
      #
      # @return [Integer] The HTTP status code, defaults to 200
      def status_code
        code = @status_code ||= 200
        @status_code = 200 if reset_status_code
        code
      end

      def reset_status_code
        @reset_status_code ||= false
      end

      # Provides dynamic access to request lists by name
      #
      # @param type [String] Request type
      # @return Request list for the type given
      def list_for(type)
        case type
        when 'error', 'errors'
          errors
        when 'session', 'sessions'
          sessions
        else
          raise "Invalid request type '#{type}'"
        end
      end

      # A list of error requests received
      #
      # @return [RequestList] Received error requests
      def errors
        @errors ||= RequestList.new
      end

      # A list of session requests received
      #
      # @return [RequestList] Received error requests
      def sessions
        @sessions ||= RequestList.new
      end

      # Whether the server thread is running
      # An array of any invalid requests received.
      # Each request is hash consisting of:
      #   request: The original HTTPRequest object
      #   reason: Reason for being considered invalid. Examples include invalid JSON and missing/invalid digest.
      # @return [Array] An array of received requests
      def invalid_requests
        @invalid_requests ||= []
      end

      # Whether the server thread is running
      #
      # @return [Boolean] If the server is running
      def running?
        @thread&.alive?
      end

      # Starts the WEBrick server in a separate thread
      def start
        attempts = 0
        $logger.info "Maze Runner v#{Maze::VERSION}"
        $logger.info 'Starting mock server'
        loop do
          @thread = Thread.new do
            server = WEBrick::HTTPServer.new(
              Port: PORT,
              Logger: $logger,
              AccessLog: []
            )
            # When adding more endpoints, be sure to update the 'I should receive no requests' step
            server.mount '/notify', Servlet, errors
            server.mount '/sessions', Servlet, sessions
            server.start
          rescue StandardError => e
            $logger.warn "Failed to start mock server: #{e.message}"
          ensure
            server&.shutdown
          end

          # Need a short sleep here as a dying thread is still alive momentarily
          sleep 1
          break if running?

          # Bail out after 3 attempts
          attempts += 1
          raise 'Too many failed attempts to start mock server' if attempts == 3

          # Failed to start - sleep before retrying
          $logger.info 'Retrying in 5 seconds'
          sleep 5
        end
      end

      # Stops the WEBrick server thread if it's running
      def stop
        @thread&.kill if @thread&.alive?
        @thread = nil
      end
    end
  end
end
