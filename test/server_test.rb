# frozen_string_literal: true

require 'cucumber'
require 'test_helper'
require 'webrick'
require_relative '../lib/maze'
require_relative '../lib/maze/generator'
require_relative '../lib/maze/servlets/base_servlet'
require_relative '../lib/maze/servlets/servlet'
require_relative '../lib/maze/servlets/command_servlet'
require_relative '../lib/maze/servlets/log_servlet'
require_relative '../lib/maze/servlets/trace_servlet'
require_relative '../lib/maze/server'

# noinspection RubyNilAnalysis
module Maze
  class ServerTest < Test::Unit::TestCase

    BIND_ADDRESS = '1.2.3.4'
    PORT = 1234

    def setup
      @logger_mock = mock('logger')
      $logger = @logger_mock
      Maze.config.bind_address = nil
      Maze.config.port = PORT
    end

    def test_start_cleanily_configured_bind_address
      # Expected logging calls
      @logger_mock.expects(:info).with('Starting mock server')

      # Pre-set securerandom output to avoid issues with generated UUIDs
      gen_uuid = 'random_uuid'
      SecureRandom.expects(:uuid).once.returns(gen_uuid)
      @logger_mock.expects(:info).with("Fixture commands UUID: #{gen_uuid}")

      # Force synchronous execution
      Thread.expects(:new).yields

      # Expected HTTP server calls
      mock_http_server = mock('http')
      mock_http_server.expects(:mount_proc).with('/', any_parameters).once
      mock_http_server.expects(:mount).with('/notify', any_parameters).once
      mock_http_server.expects(:mount).with('/sessions', any_parameters).once
      mock_http_server.expects(:mount).with('/builds', any_parameters).once
      mock_http_server.expects(:mount).with('/uploads', any_parameters).once
      mock_http_server.expects(:mount).with('/sourcemap', any_parameters).once
      mock_http_server.expects(:mount).with('/traces', any_parameters).once
      mock_http_server.expects(:mount).with('/react-native-source-map', any_parameters).once
      mock_http_server.expects(:mount).with('/command', any_parameters).once
      mock_http_server.expects(:mount).with('/logs', any_parameters).once

      mock_http_server.expects(:start)
      mock_http_server.expects(:shutdown)

      # Expected WEBrick instantiation
      Maze.config.bind_address = BIND_ADDRESS
      WEBrick::HTTPServer.expects(:new).with(BindAddress: BIND_ADDRESS,
                                             Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).returns(mock_http_server)

      # End of first and only loop
      Maze::Server.expects(:sleep).with(1)
      Maze::Server.expects(:running?).returns(true)

      # Call the method
      Maze::Server.start
    end

    def test_start_on_retry
      # Expected logging calls
      @logger_mock.expects(:info).with('Starting mock server')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')

      # Pre-set securerandom output to avoid issues with generated UUIDs
      gen_uuid = 'random_uuid'
      SecureRandom.expects(:uuid).once.returns(gen_uuid)
      @logger_mock.expects(:info).with("Fixture commands UUID: #{gen_uuid}")

      # Force synchronous execution
      Thread.expects(:new).yields.twice

      # Fails to start first time
      WEBrick::HTTPServer.expects(:new).with(Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).throws('Failed to start')

      # Successful the second
      mock_http_server = mock('http')
      mock_http_server.expects(:mount_proc).with('/', any_parameters).once
      mock_http_server.expects(:mount).with('/notify', any_parameters).once
      mock_http_server.expects(:mount).with('/sessions', any_parameters).once
      mock_http_server.expects(:mount).with('/builds', any_parameters).once
      mock_http_server.expects(:mount).with('/uploads', any_parameters).once
      mock_http_server.expects(:mount).with('/sourcemap', any_parameters).once
      mock_http_server.expects(:mount).with('/traces', any_parameters).once
      mock_http_server.expects(:mount).with('/react-native-source-map', any_parameters).once
      mock_http_server.expects(:mount).with('/logs', any_parameters).once
      mock_http_server.expects(:mount).with('/command', any_parameters).once
      mock_http_server.expects(:start)
      mock_http_server.expects(:shutdown)
      WEBrick::HTTPServer.expects(:new).with(Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).returns(mock_http_server)

      # End of loop
      Maze::Server.expects(:sleep).with(1).twice
      Maze::Server.expects(:sleep).with(5)
      Maze::Server.expects(:running?).twice.returns(false).then.returns(true)

      # Call the method
      Maze::Server.start
    end

    def test_start_fails
      # Expected logging calls
      @logger_mock.expects(:info).with('Starting mock server')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')

      # Pre-set securerandom output to avoid issues with generated UUIDs
      gen_uuid = 'random_uuid'
      SecureRandom.expects(:uuid).once.returns(gen_uuid)
      @logger_mock.expects(:info).with("Fixture commands UUID: #{gen_uuid}")

      # Force synchronous execution
      Thread.expects(:new).yields.times(3)

      # Fails to start every time
      WEBrick::HTTPServer.expects(:new).with(Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).throws('Failed to start')
      WEBrick::HTTPServer.expects(:new).with(Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).throws('Failed to start')
      WEBrick::HTTPServer.expects(:new).with(Port: PORT,
                                             Logger: @logger_mock,
                                             AccessLog: []).throws('Failed to start')

      # End of loop
      Maze::Server.expects(:sleep).with(1).times(3)
      Maze::Server.expects(:sleep).with(5).twice
      Maze::Server.expects(:running?).twice.returns(false).times(3)

      # Call the method
      assert_raise RuntimeError do
        Maze::Server.start
      end
    end

    def test_set_status_code_generator_specific_verb
      values = [401, 402, 403]
      Maze::Server.set_status_code_generator(Maze::Generator.new(values.to_enum), 'OPTIONS')

      # Other verbs use the default status code
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('POST')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('PUT')

      # Values for OPTIONS are returned in turn
      assert_equal values[0], Maze::Server.status_code('OPTIONS')
      assert_equal values[1], Maze::Server.status_code('OPTIONS')
      assert_equal values[2], Maze::Server.status_code('OPTIONS')

      # Default code is given for OPTIONS once the list is empty
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('OPTIONS')
    end

    def test_set_status_code_generator_all_verbs
      values = [401, 402, 403]
      Maze::Server.set_status_code_generator(Maze::Generator.new(values.to_enum))

      # Values for OPTIONS are returned in turn no matter which verb is used
      assert_equal values[0], Maze::Server.status_code('OPTIONS')
      assert_equal values[1], Maze::Server.status_code('POST')
      assert_equal values[2], Maze::Server.status_code('PUT')

      # Default code is given once the list is empty
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('OPTIONS')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('PUT')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('POST')
    end
  end
end
