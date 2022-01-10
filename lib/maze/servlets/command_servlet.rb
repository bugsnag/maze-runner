# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Receives log requests sent from the test fixture
    class CommandServlet < WEBrick::HTTPServlet::AbstractServlet
      # Serves the next command, if these is one.
      #
      # @param _request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(_request, response)
        $logger.info 'Asked for a command'

        response.header['Access-Control-Allow-Origin'] = '*'

        commands = Maze::Server.commands
        if commands.empty?
          response.body = 'No commands to provide'
          response.status = 400
        else
          response.body = JSON.pretty_generate(commands.current)
          response.status = 200
          commands.next
        end

        $logger.info "Provided command response: #{response.body.inspect}"
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        log_request(request)
        response.header['Access-Control-Allow-Origin'] = '*'
        response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.header['Access-Control-Allow-Headers'] = %w[Accept
                                                             Bugsnag-Api-Key Bugsnag-Integrity
                                                             Bugsnag-Payload-Version
                                                             Bugsnag-Sent-At Content-Type
                                                             Origin].join(',')

        response.status = Server.status_code
      end
    end
  end
end
