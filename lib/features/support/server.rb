# frozen_string_literal: true

require 'json'
require 'singleton'
require 'webrick'
require_relative './servlet'
require_relative './logger'

# Receives and stores requests through a WEBrick HTTPServer
class Server
  include Singleton

  # There are some constraints on the port from driving remote browsers on BrowserStack.
  # E.g. the ports/ranges that Safari will access on "localhost" urls are restricted to the following:
  #   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999 [ from https://stackoverflow.com/a/28678652 ]
  PORT = 9339

  def initialize
    @all_notify_requests = []
    @remaining_notify_requests = []
  end

  # Whether the server thread is running
  #
  # @return [Boolean] If the server is running
  def running?
    @thread&.alive?
  end

  def store_notify_request(request)
    @all_notify_requests.append request.clone
    @remaining_notify_requests.append request.clone
  end

  def take_next_notify_request
    @remaining_notify_requests.shift
  end

  def all_notify_requests
    @all_notify_requests.clone.freeze
  end

  def clear_all_requests
    @all_notify_requests.clear
    @remaining_notify_requests.clear
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

