# frozen_string_literal: true

require 'json'
require 'securerandom'
require 'webrick'
require_relative './logger'
require_relative './request_list'

module Maze
  # Receives and stores requests through a WEBrick HTTPServer
  class Server
    ALLOWED_HTTP_VERBS = %w[OPTIONS GET POST PUT DELETE HEAD TRACE PATCH CONNECT]
    DEFAULT_STATUS_CODE = 200

    class << self
      # Allows overwriting of the trace sampling probability
      attr_writer :sampling_probability

      # Dictates if the probability should be reset after use
      attr_writer :reset_sampling_probability

      # Allows a delay in milliseconds before responding to HTTP requests to be set
      attr_writer :response_delay_ms

      # Dictates if the response delay should be reset after use
      attr_writer :reset_response_delay

      # @return [String] The UUID attached to all command requests for this session
      attr_reader :command_uuid

      # Sets the status code generator for the HTTP verb given.  If no verb is given then the
      # generator will be shared across all allowable HTTP verbs.
      #
      # @param verb [String] HTTP verb
      def set_status_code_generator(generator, verb = nil)
        @generators ||= {}
        Array(verb || ALLOWED_HTTP_VERBS).each do |verb|
          old = @generators[verb]
          @generators[verb] = generator

          # Close the old generator unless it's still being used by another verb
          old&.close unless @generators.value?(old)
        end
      end

      # The intended HTTP status code on a successful request
      #
      # @param verb [String] HTTP verb for which the status code is wanted
      #
      # @return [Integer] The HTTP status code for the verb given
      def status_code(verb)
        if @generators[verb].nil? || @generators[verb].empty?
          DEFAULT_STATUS_CODE
        else
          @generators[verb].next
        end
      end

      def sampling_probability
        probability = @sampling_probability ||= '1'
        @sampling_probability = '1' if reset_sampling_probability
        probability
      end

      def reset_sampling_probability
        @reset_sampling_probability ||= false
      end

      def response_delay_ms
        delay = @response_delay_ms ||= 0
        @response_delay_ms = 0 if reset_response_delay
        delay
      end

      def reset_response_delay
        @reset_response_delay ||= false
      end

      # Provides dynamic access to request lists by name
      #
      # @param type [String, Symbol] Request type
      # @return Request list for the type given
      def list_for(type)
        type = type.to_s
        case type
        when 'error', 'errors'
          errors
        when 'session', 'sessions'
          sessions
        when 'build', 'builds'
          builds
        when 'log', 'logs'
          logs
        when 'trace', 'traces'
          traces
        when 'upload', 'uploads'
          uploads
        when 'sourcemap', 'sourcemaps'
          sourcemaps
        when 'invalid', 'invalid requests'
          invalid_requests
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

      # A list of trace requests received
      #
      # @return [RequestList] Received error requests
      def traces
        @traces ||= RequestList.new
      end

      # A list of build requests received
      #
      # @return [RequestList] Received build requests
      def builds
        @builds ||= RequestList.new
      end

      # A list of upload requests received
      #
      # @return [RequestList] Received upload requests
      def uploads
        @uploads ||= RequestList.new
      end

      # A list of sourcemap requests received
      #
      # @return [RequestList] Received sourcemap requests
      def sourcemaps
        @sourcemaps ||= RequestList.new
      end

      # A list of log requests received
      #
      # @return [RequestList] Received log requests
      def logs
        @logs ||= RequestList.new
      end

      # A list of commands for a test fixture to perform.  Strictly speaking these are responses to HTTP
      # requests, but the list behavior is all we need.
      #
      # @return [RequestList] Commands to be performed
      def commands
        @commands ||= RequestList.new
      end

      # Whether the server thread is running
      # An array of any invalid requests received.
      # Each request is hash consisting of:
      #   request: The original HTTPRequest object
      #   reason: Reason for being considered invalid. Examples include invalid JSON and missing/invalid digest.
      # @return [RequestList] An array of received requests
      def invalid_requests
        @invalid_requests ||= RequestList.new
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
        @command_uuid = SecureRandom.uuid
        $logger.info "Fixture commands UUID: #{@command_uuid}"
        loop do

          @thread = Thread.new do
            options = {
                Port: Maze.config.port,
                Logger: $logger,
                AccessLog: []
            }
            options[:BindAddress] = Maze.config.bind_address unless Maze.config.bind_address.nil?
            server = WEBrick::HTTPServer.new(options)

            # Mount a block to respond to all requests with status:200
            server.mount_proc '/' do |_request, response|
              $logger.info 'Received request on server root, responding with 200'
              response.header['Access-Control-Allow-Origin'] = '*'
              response.body = 'Maze runner received request'
              response.status = 200
            end

            # When adding more endpoints, be sure to update the 'I should receive no requests' step
            server.mount '/notify', Servlets::Servlet, :errors
            server.mount '/sessions', Servlets::Servlet, :sessions
            server.mount '/builds', Servlets::Servlet, :builds
            server.mount '/uploads', Servlets::Servlet, :uploads
            server.mount '/sourcemap', Servlets::Servlet, :sourcemaps
            server.mount '/traces', Servlets::TraceServlet, :traces
            server.mount '/react-native-source-map', Servlets::Servlet, :sourcemaps
            server.mount '/command', Servlets::CommandServlet
            server.mount '/logs', Servlets::LogServlet
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

      def reset!
        Maze::Server.errors.clear
        Maze::Server.sessions.clear
        Maze::Server.builds.clear
        Maze::Server.uploads.clear
        Maze::Server.sourcemaps.clear
        Maze::Server.traces.clear
        Maze::Server.logs.clear
        Maze::Server.invalid_requests.clear
        @generators&.values&.each { |generator| generator.close }
      end
    end
  end
end
