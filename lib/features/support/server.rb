# frozen_string_literal: true

require 'webrick'
require 'json'
require_relative './servlet'

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
      @thread = Thread.new do
        server = WEBrick::HTTPServer.new(
          Port: MOCK_API_PORT,
          Logger: $logger,
          AccessLog: [],
        )
        server.mount '/', Servlet
        begin
          server.start
        ensure
          server.shutdown
        end
      end
    end

    # Stops the WEBrick server thread if it's running
    def stop_server
      @thread.kill if @thread&.alive?
      @thread = nil
    end
  end
end

# Before all tests
Server.start_server

# After all tests
at_exit do
  Server.stop_server
end

# Before each test
Before do
  Server.stored_requests.clear
  unless Server.running?
    $logger.fatal "Mock server is not running on #{MOCK_API_PORT}"
    exit(1)
  end
end
