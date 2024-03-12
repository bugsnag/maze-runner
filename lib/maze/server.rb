# frozen_string_literal: true

require 'bugsnag'
require 'json'
require 'webrick'
require_relative 'loggers/logger'
require_relative './request_list'

module Maze
  # Receives and stores requests through a WEBrick HTTPServer
  class Server
    ALLOWED_HTTP_VERBS = %w[OPTIONS GET POST PUT DELETE HEAD TRACE PATCH CONNECT]
    DEFAULT_RESPONSE_DELAY = 0
    DEFAULT_SAMPLING_PROBABILITY = 1
    DEFAULT_STATUS_CODE = 200

    class << self
      # Sets the response delay generator.
      #
      # @param generator [Maze::Generator] The new generator
      def set_response_delay_generator(generator)
        @response_delay_generator&.close
        @response_delay_generator = generator
      end

      # Sets the sampling probability generator.
      #
      # @param generator [Maze::Generator] The new generator
      def set_sampling_probability_generator(generator)
        @sampling_probability_generator&.close
        @sampling_probability_generator = generator
      end

      # Sets the status code generator for the HTTP verb given.  If no verb is given then the
      # generator will be shared across all allowable HTTP verbs.
      #
      # @param generator [Maze::Generator] The new generator
      # @param verb [String] HTTP verb
      def set_status_code_generator(generator, verb = nil)
        @status_code_generators ||= {}
        Array(verb || ALLOWED_HTTP_VERBS).each do |verb|
          old = @status_code_generators[verb]
          @status_code_generators[verb] = generator

          # Close the old generator unless it's still being used by another verb
          old&.close unless @status_code_generators.value?(old)
        end
      end

      # The intended HTTP status code on a successful request
      #
      # @param verb [String] HTTP verb for which the status code is wanted
      #
      # @return [Integer] The HTTP status code for the verb given
      def status_code(verb)
        if @status_code_generators[verb].nil? || @status_code_generators[verb].closed?
          DEFAULT_STATUS_CODE
        else
          @status_code_generators[verb].next
        end
      end

      def sampling_probability
        @sampling_probability_generator.next
      end

      def response_delay_ms
        @response_delay_generator.next
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
        when 'metric', 'metrics'
          metrics
        when 'sampling request', 'sampling requests'
          sampling_requests
        when 'trace', 'traces'
          traces
        when 'upload', 'uploads'
          uploads
        when 'sourcemap', 'sourcemaps'
          sourcemaps
        when 'reflect', 'reflects', 'reflection', 'reflections'
          reflections
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
      # @return [RequestList] Received session requests
      def sessions
        @sessions ||= RequestList.new
      end

      # A list of sampling requests received
      #
      # @return [RequestList] Received sampling requests
      def sampling_requests
        @sampling_requests ||= RequestList.new
      end

      # A list of trace requests received
      #
      # @return [RequestList] Received trace requests
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

      # A list of metric requests received
      #
      # @return [RequestList] Received metric requests
      def metrics
        @metrics ||= RequestList.new
      end

      # A list of reflection requests received
      #
      # @return [RequestList] Received reflection requests
      def reflections
        @reflections ||= RequestList.new
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
              $logger.trace 'Received request on server root, responding with 200'
              response.header['Access-Control-Allow-Origin'] = '*'
              response.body = 'Maze runner received request'
              response.status = 200
            end

            # When adding more endpoints, be sure to update the 'I should receive no requests' step
            server.mount '/notify', Servlets::Servlet, :errors
            server.mount '/sessions', Servlets::Servlet, :sessions
            server.mount '/builds', Servlets::Servlet, :builds
            server.mount '/uploads', Servlets::Servlet, :uploads
            server.mount '/traces', Servlets::TraceServlet, :traces, Maze::Schemas::TRACE_SCHEMA
            server.mount '/sourcemap', Servlets::Servlet, :sourcemaps
            server.mount '/react-native-source-map', Servlets::Servlet, :sourcemaps
            server.mount '/dart-symbol', Servlets::Servlet, :sourcemaps
            server.mount '/ndk-symbol', Servlets::Servlet, :sourcemaps
            server.mount '/proguard', Servlets::Servlet, :sourcemaps
            server.mount '/dsym', Servlets::Servlet, :sourcemaps
            server.mount '/command', Servlets::CommandServlet
            server.mount '/commands', Servlets::AllCommandsServlet
            server.mount '/logs', Servlets::LogServlet
            server.mount '/metrics', Servlets::Servlet, :metrics
            server.mount '/reflect', Servlets::ReflectiveServlet
            server.start
          rescue StandardError => e
            Bugsnag.notify e
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
        # Reset generators
        set_response_delay_generator(Maze::Generator.new [DEFAULT_RESPONSE_DELAY].cycle)
        set_status_code_generator(Maze::Generator.new [DEFAULT_STATUS_CODE].cycle)
        set_sampling_probability_generator(Maze::Generator.new [DEFAULT_SAMPLING_PROBABILITY].cycle)

        # Clear request lists
        commands.clear
        errors.clear
        sessions.clear
        builds.clear
        uploads.clear
        sourcemaps.clear
        sampling_requests.clear
        traces.clear
        logs.clear
        invalid_requests.clear
        reflections.clear
      end
    end
  end
end
