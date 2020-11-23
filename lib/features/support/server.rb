# frozen_string_literal: true

require 'webrick'
require 'json'
require_relative './servlet'
require_relative './logger'

# This port number is semi-arbitrary. It doesn't matter for the sake of
# the application what it is, but there are some constraints due to some
# of the environments that we know this will be used in - namely, driving
# remote browsers on BrowserStack. The ports/ranges that Safari will access
# on "localhost" urls are restricted to the following:
#
#   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999
#   [ from https://stackoverflow.com/a/28678652 ]
#
MOCK_API_PORT = 9339

# Receives and stores requests through a WEBrick HTTPServer
class Server
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

    # Whether the server thread is running
    #
    # @return [Boolean] If the server is running
    def running?
      @thread&.alive?
    end

    # An array of (deemed to be valid) requests received.
    # Each request is hash consisting of:
    #   body: The parsed body of the request
    #   request: The original HTTPRequest object
    #   digests: (for JSON requests only) the computed digests for the body
    #
    # @return [Array] An array of received requests
    def stored_requests
      @stored_requests ||= []
    end

    # An array of any invalid requests received.
    # Each request is hash consisting of:
    #   request: The original HTTPRequest object
    #   reason: Reason for being considered invalid. Examples include invalid JSON and missing/invalid digest.
    # @return [Array] An array of received requests
    def invalid_requests
      @invalid_requests ||= []
    end

    # The first request received by the server.
    #
    # @return [Hash|nil] The first request
    def current_request
      stored_requests.first
    end

    # Starts the WEBrick server in a separate thread
    def start_server
      attempts = 0
      $logger.info 'Starting mock server'
      loop do
        @thread = Thread.new do
          server = WEBrick::HTTPServer.new(
            Port: MOCK_API_PORT,
            Logger: $logger,
            AccessLog: []
          )
          server.mount '/', Servlet
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
    def stop_server
      @thread&.kill if @thread&.alive?
      @thread = nil
    end
  end
end

