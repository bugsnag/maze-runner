# frozen_string_literal: true

require 'webrick'

module Maze
  # HTTP server for a given document root
  class DocumentServer
    class << self
      # Start the document server.  This is intended to be called only once per test run.
      # Use manual_start for finer grained control.
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
          server.mount '/reflect', Servlets::ReflectiveServlet

          $logger.info "Starting document server for root: #{Maze.config.document_server_root}"
          server.start
        end
      end

      # Starts the document server "manually" (via a Cucumber step as opposed to command line option)
      def manual_start
        if !@thread.nil? && @thread.alive?
          $logger.warn 'Document Server has already been started on the command line, ignoring manual start'
          return
        end
        @manual_start = true
        start
      end

      def manual_stop
        return unless  @manual_start

        @thread.kill
        @manual_start = false
      end
    end
  end
end
