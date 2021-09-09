# frozen_string_literal: true

require 'webrick'

module Maze
  # HTTP server for a given document root
  class DocumentServer
    class << self
      def start
        @thread = Thread.new do
          options = {
              DocumentRoot: Maze.config.document_server_root,
              Port: Maze.config.document_server_port,
              Logger: $logger,
              AccessLog: []
          }
          options[:BindAddress] = Maze.config.document_server_bind_address unless Maze.config.document_server_bind_address.nil?
          server = WEBrick::HTTPServer.new(options)
          server.mount '/reflect', ReflectiveServlet

          $logger.info "Starting document server for root: #{Maze.config.document_server_root}"
          server.start
        end
      end
    end
  end
end
