# frozen_string_literal: true

require 'json'

module Maze
  module Servlets

    # Allows clients to queue up "commands", in the form of Ruby hashes, using Maze::Server.commands.add.  GET
    # requests made to the /command endpoint will then respond with each queued command in turn.
    class IdempotentCommandServlet < BaseServlet

      NOOP_COMMAND = '{"action": "noop", "message": "No commands queued"}'
      RESET_COMMAND = '{"action": "reset_uuid", "message": "The UUID given was unknown - client must reset its last known UUID"}'

      # Serves the next command, if there is one.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_GET(request, response)
        after_uuid = request.query['after']
        if after_uuid.nil?
          response.body = "The 'after' query parameter must be provided, but may be an empty string"
          response.status = 400
        else
          command_after(after_uuid, response)
        end

        response.header['Access-Control-Allow-Origin'] = '*'
      end

      def send_current_command(response)
        commands = Maze::Server.commands

        if commands.size_remaining == 0
          response.body = NOOP_COMMAND
          response.status = 200
        else
          command = commands.current
          response.body = JSON.pretty_generate(command)
          response.status = 200
          commands.next
        end
      end

      def command_after(uuid, response)
        commands = Maze::Server.commands
        if uuid.empty?
          # Return the first command in the list, if there is one
          index = -1
        else
          # Find the matching command
          index = commands.all.find_index {|command| command[:uuid] == uuid }
        end

        if index.nil?
          # No matching command - client must reset its UUID
          response.body = RESET_COMMAND
          response.status = 400
        else
          if index + 1 < commands.size_all
            # Respond with the next command in the queue
            command = commands.get(index + 1)
            command_json = JSON.pretty_generate(command)
            response.body = command_json
            response.status = 200
          else
            # The UUID given was for the last command in the list
            response.body = NOOP_COMMAND
            response.status = 200
          end
        end
      end

      # Logs and returns a set of valid headers for this servlet.
      #
      # @param request [HTTPRequest] The incoming GET request
      # @param response [HTTPResponse] The response to return
      def do_OPTIONS(request, response)
        super

        response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.status = Server.status_code('OPTIONS')
      end
    end
  end
end
