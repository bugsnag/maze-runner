# frozen_string_literal: true

module Maze
  module Servlets

    # Base servlet to avoid duplication of common code
    class BaseServlet < WEBrick::HTTPServlet::AbstractServlet
      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        response.header['Access-Control-Allow-Origin'] = '*'
        response.header['Access-Control-Allow-Headers'] = %w[
          Accept
          Bugsnag-Api-Key
          Bugsnag-Integrity
          Bugsnag-Payload-Version
          Bugsnag-Sent-At
          Bugsnag-Span-Sampling
          Content-Type
          Origin
        ].join(',')
      end
    end
  end
end
