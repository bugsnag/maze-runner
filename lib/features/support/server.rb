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
    # Whether the server thread is running
    #
    # @return [Boolean] If the server is running
    def running?
      @thread&.alive?
    end

    # An array of requests received.
    # Each request is hash consisting of:
    #   body: The parsed body of the request
    #   request: The original HTTPRequest object
    #
    # @return [Array] An array of received requests
    def stored_requests
      @stored_requests ||= []
    end

    # The first request received by the server.
    #
    # @return [Hash|nil] The first request
    def current_request
      stored_requests.first
    end

    # Starts the WEBrick server in a separate thread
    def start_server
      loop do
        $logger.info 'Starting mock server'
        @thread = Thread.new do
          server = WEBrick::HTTPServer.new(
            Port: MOCK_API_PORT,
            Logger: $logger,
            AccessLog: []
          )
          server.mount '/', Servlet
          server.start
        rescue StandardError => e
          $logger.warn "Failed to start mock server, retrying in 5 seconds: #{e.message}"
        ensure
          server&.shutdown
        end

        # Need a short sleep here as a dying thread is still alive momentarily
        sleep 1
        break if running?

        # Failed to start - sleep before retrying
        sleep 4
      end
    end

    # Stops the WEBrick server thread if it's running
    def stop_server
      @thread&.kill if @thread&.alive?
      @thread = nil
    end
  end
end

