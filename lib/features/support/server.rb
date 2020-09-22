# frozen_string_literal: true

require 'json'
require 'webrick'
require_relative './servlet'
require_relative './logger'
require_relative './request_list'

# Receives and stores requests through a WEBrick HTTPServer
class Server

  class << self

    # There are some constraints on the port from driving remote browsers on BrowserStack.
    # E.g. the ports/ranges that Safari will access on "localhost" urls are restricted to the following:
    #   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999 [ from https://stackoverflow.com/a/28678652 ]
    PORT = 9339

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
    #
    # @return [Boolean] If the server is running
    def running?
      @thread&.alive?
    end

    # Starts the WEBrick server in a separate thread
    def start
      attempts = 0
      $logger.info 'Starting mock server'
      loop do
        @thread = Thread.new do
          server = WEBrick::HTTPServer.new(
            Port: PORT,
            Logger: $logger,
            AccessLog: []
          )
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
