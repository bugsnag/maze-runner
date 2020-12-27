# frozen_string_literal: true

require 'cucumber'
require 'test_helper'
require 'webrick'
require_relative '../lib/features/support/server'

# noinspection RubyNilAnalysis
class ServerTest < Test::Unit::TestCase

  def setup
    @logger_mock = mock('logger')
    $logger = @logger_mock
  end

  def test_start_cleanily
    # Expected logging calls
    @logger_mock.expects(:info).with("Maze Runner v#{Maze::VERSION}")
    @logger_mock.expects(:info).with('Starting mock server')

    # Force synchronous execution
    Thread.expects(:new).yields

    # Expected HTTP server calls
    mock_http_server = mock('http')
    mock_http_server.expects(:mount).twice
    mock_http_server.expects(:start)
    mock_http_server.expects(:shutdown)

    # Expected WEBrick instantiation
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).returns(mock_http_server)

    # End of first and only loop
    Server.expects(:sleep).with(1)
    Server.expects(:running?).returns(true)

    # Call the method
    Server.start
  end

  def test_start_on_retry
    # Expected logging calls
    @logger_mock.expects(:info).with("Maze Runner v#{Maze::VERSION}")
    @logger_mock.expects(:info).with('Starting mock server')
    @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
    @logger_mock.expects(:info).with('Retrying in 5 seconds')

    # Force synchronous execution
    Thread.expects(:new).yields.twice

    # Fails to start first time
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).throws('Failed to start')

    # Successful the second
    mock_http_server = mock('http')
    mock_http_server.expects(:mount).twice
    mock_http_server.expects(:start)
    mock_http_server.expects(:shutdown)
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).returns(mock_http_server)

    # End of loop
    Server.expects(:sleep).with(1).twice
    Server.expects(:sleep).with(5)
    Server.expects(:running?).twice.returns(false).then.returns(true)

    # Call the method
    Server.start
  end

  def test_start_fails
    # Expected logging calls
    @logger_mock.expects(:info).with("Maze Runner v#{Maze::VERSION}")
    @logger_mock.expects(:info).with('Starting mock server')
    @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
    @logger_mock.expects(:info).with('Retrying in 5 seconds')
    @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')
    @logger_mock.expects(:info).with('Retrying in 5 seconds')
    @logger_mock.expects(:warn).with('Failed to start mock server: uncaught throw "Failed to start"')

    # Force synchronous execution
    Thread.expects(:new).yields.times(3)

    # Fails to start every time
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).throws('Failed to start')
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).throws('Failed to start')
    WEBrick::HTTPServer.expects(:new).with(Port: Server::PORT,
                                           Logger: @logger_mock,
                                           AccessLog: []).throws('Failed to start')

    # End of loop
    Server.expects(:sleep).with(1).times(3)
    Server.expects(:sleep).with(5).twice
    Server.expects(:running?).twice.returns(false).times(3)

    # Call the method
    assert_raise RuntimeError do
      Server.start
    end
  end
end
