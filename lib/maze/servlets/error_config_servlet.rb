# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to request error configs that have been added to the queue.
    class ErrorConfigServlet < BaseServlet

      BAD_REQUEST_BODY = '{
        "type":"about:blank",
        "title":"Bad Request",
        "status":400,
        "detail":"Maze Runner has not been given an error config to return"
      }'

      # Captures the details of the request for checking and serves the next error config, if there is one.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)

        if Server.error_configs.size_remaining > 0
          # Server the next error config in the queue
          error_config = Server.error_configs.current
          error_config[:headers].each do |key, value|
            response.header[key] = value
          end
          response.body = error_config[:body]
          response.status = error_config[:status]

          Server.error_configs.next
        else
          # Log and return an error
          $logger.error 'Error config requested but none are queued - returning 400 Bad Request'
          response.body = BAD_REQUEST_BODY
          response.status = 400
        end
        response.header['Content-Type'] = 'application/json'

        # Store the query parameters in the error config request list
        details = {
          body: {},
          query: Rack::Utils.parse_nested_query(request.query_string),
          request_uri: request.request_uri,
          request: request,
          response: response,
          method: 'GET'
        }
        Server.error_config_requests.add(details)
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
        response.status = Server.status_code('OPTIONS')
      end
    end
  end
end
