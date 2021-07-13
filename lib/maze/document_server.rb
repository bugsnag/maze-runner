# frozen_string_literal: true

require 'webrick'

module Maze
  # HTTP server for a given document root
  class DocumentServer

    class << self

      def start
        @thread = Thread.new do
          options = {
              Port: Maze.config.ds_port,
              Logger: $logger,
              AccessLog: []
          }
          options[:BindAddress] = Maze.config.ds_bind_address unless Maze.config.ds_bind_address.nil?
          server = WEBrick::HTTPServer.new :Port => Maze.config.ds_port, :DocumentRoot => Maze.config.ds_root
          $logger.info "Starting document server for root: #{Maze.config.ds_root}"
          server.start
        end
      end
    end
  end
end

