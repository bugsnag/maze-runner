# frozen_string_literal: true
require 'bugsnag'
require 'rack'

module Maze
  module Servlets
    # Receives HTTP requests and responds according to the parameters given, which are:
    # - delay_ms - milliseconds to wait before responding
    # - status - HTTP response code
    # For GET requests these are expected to passed as GET parameters,
    # for POST requests they are expected to be given as JSON fields.
    class ReflectiveServlet < BaseServlet

      # Accepts a GET request to provide a reflective response to.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)
        delay_ms = request.query['delay_ms']
        status = request.query['status']
        reflect response, delay_ms, status
      end

      # Accepts a POST request to provide a reflective response to.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_POST(request, response)

        content_type = request['Content-Type']

        # For JSON, pull the instructions from the body.  Otherwise, take them from the query string.
        if content_type == 'application/json'
          body = JSON.parse(request.body)
          delay_ms = body['delay_ms']
          status = body['status']
        else
          query = Rack::Utils.parse_nested_query(request.query_string)
          delay_ms = query['delay_ms']
          status = query['status']
        end

        reflect response, delay_ms, status
      rescue JSON::ParserError => e
        Bugsnag.notify e
        msg = "Unable to parse request as JSON: #{e.message}"
        $logger.error msg
        response.status = 418
      rescue StandardError => e
        Bugsnag.notify e
        $logger.error "Invalid request: #{e.message}"
        response.status = 500
      end

      def reflect(response, delay_ms, status)
        sleep delay_ms.to_i / 1000 unless delay_ms.nil?
        response.status = status || 200
        response.header['Access-Control-Allow-Origin'] = '*'
        response.body = "Returned status #{status} after waiting #{delay_ms} ms"
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
      end
    end
  end
end
