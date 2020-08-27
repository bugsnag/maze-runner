# frozen_string_literal: true

require 'cucumber'
require 'test_helper'
require 'webrick'
require_relative '../lib/features/support/server'

class ServerTest < Test::Unit::TestCase

  def start_logger_mock
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock
  end

  def test_start_server_cleanily

    # Force synchronous execution
    Thread.expects(:new).yields

    # Expected logging calls
    mock_logger = start_logger_mock
    mock_logger.expects(:info).with('Starting mock server')

    # Expected HTTP server calls
    mock_http_server = mock('http')
    mock_http_server.expects(:mount)
    mock_http_server.expects(:start)
    mock_http_server.expects(:shutdown)

    # Expected WEBrick instantiation
    WEBrick::HTTPServer.expects(:new).with(Port: MOCK_API_PORT, Logger: mock_logger, AccessLog: []).returns(mock_http_server)

    # End of first and only loop
    Server.expects(:sleep).with(1)
    Server.expects(:running?).returns(true)

    # Call the method
    Server.start_server
  end

  def test_start_server_on_retry
    assert_true false
  end

  def test_start_server_fails
    assert_true false
  end
end
