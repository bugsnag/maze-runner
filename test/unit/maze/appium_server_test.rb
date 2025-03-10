# frozen_string_literal: true

require 'pty'
require 'set'
require_relative '../../../lib/maze/appium_server.rb'
require_relative '../test_helper'

class AppiumServerTest < Test::Unit::TestCase

  def setup
    logger_mock = mock('logger')
    $logger = logger_mock

    # Reset everything to default
    Maze::AppiumServer.instance_variable_set(:@pid, nil)
    Maze::AppiumServer.instance_variable_set(:@appium_thread, nil)
    Maze::AppiumServer.instance_variable_set(:@appium_logger, nil)
  end

  def test_running_default
    assert_false(Maze::AppiumServer.running)
  end

  def test_appium_available?
    Maze::AppiumServer.expects(:`).with('appium -v').returns('v1.0.0')
    assert(Maze::AppiumServer.send(:appium_available?))
  end

  def test_appium_not_available?
    Maze::AppiumServer.expects(:`).with('appium -v').raises(Errno::ENOENT)
    assert_false(Maze::AppiumServer.send(:appium_available?))
  end

  def test_appium_port_available?
    expected_port = '12345'
    response_string = ""
    Maze::AppiumServer.expects(:`).with(%(netstat -vanp tcp | awk '{ print $4 }' | grep "\.#{expected_port}$")).returns(response_string)
    assert(Maze::AppiumServer.send(:appium_port_available?, expected_port))
  end

  def test_appium_port_not_available?
    expected_port = '12345'
    response_string = "something is using the port"
    Maze::AppiumServer.expects(:`).with(%(netstat -vanp tcp | awk '{ print $4 }' | grep "\.#{expected_port}$")).returns(response_string)
    assert_false(Maze::AppiumServer.send(:appium_port_available?, expected_port))
  end

  def test_start_logger
    # Set configured logfile
    test_logfile = 'TEST_LOGFILE.log'
    Maze.config.expects(:appium_logfile).returns(test_logfile)

    # Set mock expectations for the logger
    appium_logger_mock = mock('logger')
    ::Logger.expects(:new).with(test_logfile).returns(appium_logger_mock)
    appium_logger_mock.expects(:datetime_format=).with('%Y-%m-%d %H:%M:%S')

    # Assert logger is correctly set
    Maze::AppiumServer.send(:start_logger)
    assert_equal(Maze::AppiumServer.appium_logger, appium_logger_mock)
  end

  def test_log_line_no_logger
    # This will pass if it doesn't throw
    test_line = 'foo bar'
    Maze::AppiumServer.send(:log_line,  test_line)
  end

  def test_log_line
    # Set a mock logger and PID
    appium_logger_mock = mock('logger')
    Maze::AppiumServer.instance_variable_set(:@appium_logger, appium_logger_mock)
    pid = '12345'
    Maze::AppiumServer.instance_variable_set(:@pid, pid)

    appium_logger_mock.expects(:info).with("Appium:#{pid}")
    test_line = 'foo bar'
    Maze::AppiumServer.send(:log_line,  test_line)
  end

  def test_start_default
    # Setup mocks and expectations
    thread_mock = mock('thread')
    stdin_mock = mock('stdin')
    stdout_mock = mock('stdout')
    pid = 12345

    # Corresponds to the debug call
    $logger.expects(:trace).with("Appium:#{pid}").once

    # Expect Thread.new to be called, and allow block to process expect the mock alive? to be called
    Thread.expects(:new).returns(thread_mock).yields
    thread_mock.stubs(:alive?).returns(true)

    # Expect PTY.spawn to be called, and allow block to process with mocks
    PTY.expects(:spawn).with('appium', '-a', '0.0.0.0', '-p', '4723').yields(stdout_mock, stdin_mock, pid)

    # Expect stdout.each to be called, and yield "Foo" to trigger the logger
    stdout_mock.expects(:each).yields("Foo")

    # Ensure the sleep is stubbed to avoid delays
    Maze::AppiumServer.expects(:sleep).with(2)

    # Expect appium_port_available? and appium_available? calls
    Maze::AppiumServer.expects(:appium_port_available?).with('4723').returns(true)
    Maze::AppiumServer.expects(:appium_available?).returns(true)

    # Expect the logger to be started
    Maze::AppiumServer.expects(:start_logger)

    Maze::AppiumServer.start
    assert(Maze::AppiumServer.running)
    assert_equal(Maze::AppiumServer.instance_variable_get(:@pid), pid)
    assert_equal(Maze::AppiumServer.instance_variable_get(:@appium_thread), thread_mock)
  end

  def test_start_overwritten_address_port
    thread_mock = mock('thread')
    Thread.expects(:new).returns(thread_mock).yields
    PTY.expects(:spawn).with('appium', '-a', '1.2.3.4', '-p', '5678')

    # Ensure the sleep is stubbed to avoid delays
    Maze::AppiumServer.expects(:sleep).with(2)

    # Expect appium_port_available? and appium_available? calls
    Maze::AppiumServer.expects(:appium_port_available?).with('5678').returns(true)
    Maze::AppiumServer.expects(:appium_available?).returns(true)

    Maze::AppiumServer.start(address: '1.2.3.4', port: '5678')
  end

  def test_start_with_alive_thread
    thread_mock = mock('thread')
    thread_mock.expects(:alive?).returns(true)
    Maze::AppiumServer.instance_variable_set(:@appium_thread, thread_mock)

    Thread.expects(:new).never

    Maze::AppiumServer.start
  end

  def test_start_with_exited_thread
    thread_mock = mock('thread')
    thread_mock.expects(:alive?).returns(false)
    Maze::AppiumServer.instance_variable_set(:@appium_thread, thread_mock)

    Thread.expects(:new).once

    Maze::AppiumServer.expects(:appium_port_available?).with('4723').returns(true)
    Maze::AppiumServer.expects(:appium_available?).returns(true)

    # Ensure the sleep is stubbed to avoid delays
    Maze::AppiumServer.expects(:sleep).with(2)

    Maze::AppiumServer.start
  end

  def test_start_port_unavailable
    $logger.expects(:warn).with('Requested appium port:4723 is in use. Aborting built-in appium server launch')

    Thread.expects(:new).never

    Maze::AppiumServer.expects(:appium_port_available?).with('4723').returns(false)

    Maze::AppiumServer.start
  end

  def test_start_appium_unavailable
    $logger.expects(:warn).with('Appium is unavailable to be started from the command line. Install using `npm i -g appium`')

    Thread.expects(:new).never

    Maze::AppiumServer.expects(:appium_port_available?).with('4723').returns(true)
    Maze::AppiumServer.expects(:appium_available?).returns(false)

    Maze::AppiumServer.start
  end

  def test_stop_default
    $logger.expects(:debug).never
    Maze::AppiumServer.stop
  end

  def test_stop_with_alive_thread
    thread_mock = mock('thread')
    thread_mock.expects(:alive?).returns(true)
    pid = '12345'
    Maze::AppiumServer.instance_variable_set(:@pid, pid)
    Maze::AppiumServer.instance_variable_set(:@appium_thread, thread_mock)

    thread_mock.expects(:join)
    $logger.expects(:trace).with("Appium:#{pid}")
    Process.expects(:kill).with('INT', pid)

    Maze::AppiumServer.stop

    assert_nil(Maze::AppiumServer.instance_variable_get(:@pid))
    assert_nil(Maze::AppiumServer.instance_variable_get(:@appium_thread))
  end
end
