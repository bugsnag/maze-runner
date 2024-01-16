# frozen_string_literal: true

require 'cucumber'
require 'test_helper'
require 'webrick'
require_relative '../lib/maze'
require_relative '../lib/maze/generator'
require_relative '../lib/maze/schemas/trace_schema'
require_relative '../lib/maze/repeaters/request_repeater'
require_relative '../lib/maze/servlets/base_servlet'
require_relative '../lib/maze/servlets/servlet'
require_relative '../lib/maze/servlets/all_commands_servlet'
require_relative '../lib/maze/servlets/command_servlet'
require_relative '../lib/maze/servlets/log_servlet'
require_relative '../lib/maze/servlets/trace_servlet'
require_relative '../lib/maze/servlets/reflective_servlet'
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
      Maze::Server.reset!
    end

    def test_start_cleanily_configured_bind_address

      # Force synchronous execution
      Thread.expects(:new).yields

      # Expected HTTP server calls
      mock_http_server = mock('http')
      mock_http_server.expects(:mount_proc).with('/', any_parameters).once
      mock_http_server.expects(:mount).with('/notify', any_parameters).once
      mock_http_server.expects(:mount).with('/sessions', any_parameters).once
      mock_http_server.expects(:mount).with('/builds', any_parameters).once
      mock_http_server.expects(:mount).with('/metrics', any_parameters).once
      mock_http_server.expects(:mount).with('/uploads', any_parameters).once
      mock_http_server.expects(:mount).with('/sourcemap', any_parameters).once
      mock_http_server.expects(:mount).with('/traces', any_parameters).once
      mock_http_server.expects(:mount).with('/react-native-source-map', any_parameters).once
      mock_http_server.expects(:mount).with('/dart-symbol', any_parameters).once
      mock_http_server.expects(:mount).with('/ndk-symbol', any_parameters).once
      mock_http_server.expects(:mount).with('/proguard', any_parameters).once
      mock_http_server.expects(:mount).with('/command', any_parameters).once
      mock_http_server.expects(:mount).with('/commands', any_parameters).once
      mock_http_server.expects(:mount).with('/logs', any_parameters).once
      mock_http_server.expects(:mount).with('/reflect', any_parameters).once

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
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')

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
      mock_http_server.expects(:mount).with('/metrics', any_parameters).once
      mock_http_server.expects(:mount).with('/uploads', any_parameters).once
      mock_http_server.expects(:mount).with('/sourcemap', any_parameters).once
      mock_http_server.expects(:mount).with('/traces', any_parameters).once
      mock_http_server.expects(:mount).with('/react-native-source-map', any_parameters).once
      mock_http_server.expects(:mount).with('/dart-symbol', any_parameters).once
      mock_http_server.expects(:mount).with('/ndk-symbol', any_parameters).once
      mock_http_server.expects(:mount).with('/proguard', any_parameters).once
      mock_http_server.expects(:mount).with('/logs', any_parameters).once
      mock_http_server.expects(:mount).with('/reflect', any_parameters).once
      mock_http_server.expects(:mount).with('/command', any_parameters).once
      mock_http_server.expects(:mount).with('/commands', any_parameters).once
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
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
      @logger_mock.expects(:info).with('Retrying in 5 seconds')
      @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')

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

    def create_defaulting_generator(codes)
      enumerator = Enumerator.new do |yielder|
        codes.each do |code|
          yielder.yield code
        end

        loop do
          yielder.yield Maze::Server::DEFAULT_STATUS_CODE
        end
      end
      Maze::Generator.new enumerator
    end

    def test_set_status_code_generator_specific_verb
      values = [401, 402, 403]
      generator = create_defaulting_generator(values)
      Maze::Server.set_status_code_generator(generator, 'OPTIONS')

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
      generator = create_defaulting_generator(values)
      Maze::Server.set_status_code_generator(generator)

      # Values for OPTIONS are returned in turn no matter which verb is used
      assert_equal values[0], Maze::Server.status_code('OPTIONS')
      assert_equal values[1], Maze::Server.status_code('POST')
      assert_equal values[2], Maze::Server.status_code('PUT')

      # Default code is given once the list is empty
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('OPTIONS')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('PUT')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('POST')
    end

    def test_set_status_code_generator_combined
      generic_values = [401, 402, 403, 404, 405, 406]
      generator = create_defaulting_generator(generic_values)
      Maze::Server.set_status_code_generator(generator)

      # Values for OPTIONS are returned in turn no matter which verb is used
      assert_equal generic_values[0], Maze::Server.status_code('OPTIONS')
      assert_equal generic_values[1], Maze::Server.status_code('POST')

      # Now replace the generator for PUT only
      specific_values = [501, 502]
      generator = create_defaulting_generator(specific_values)
      Maze::Server.set_status_code_generator(generator, 'PUT')

      # PUT now uses a different list while others carry on
      assert_equal specific_values[0], Maze::Server.status_code('PUT')
      assert_equal specific_values[1], Maze::Server.status_code('PUT')

      assert_equal generic_values[2], Maze::Server.status_code('POST')
      assert_equal generic_values[3], Maze::Server.status_code('POST')
      assert_equal generic_values[4], Maze::Server.status_code('DELETE')
      assert_equal generic_values[5], Maze::Server.status_code('POST')

      # Default code is given once the lists are empty
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('OPTIONS')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('PUT')
      assert_equal Maze::Server::DEFAULT_STATUS_CODE, Maze::Server.status_code('POST')
    end
  end
end
