# frozen_string_literal: true

require 'test_helper'
require 'pty'
require_relative '../lib/maze/local_appium_server.rb'

class LocalAppiumServerTest < Test::Unit::TestCase

  def setup
    logger_mock = mock('logger')
    $logger = logger_mock

    # Reset everything to default
    Maze::LocalAppiumServer.instance_variable_set(:@pid, nil)
    Maze::LocalAppiumServer.instance_variable_set(:@appium_thread, nil)
  end

  def test_running_default
    assert_false(Maze::LocalAppiumServer.running)
  end

  def test_appium_available?
    Maze::LocalAppiumServer.expects(:`).with('appium -v').returns('v1.0.0')
    assert(Maze::LocalAppiumServer.send(:appium_available?))
  end

  def test_appium_not_available?
    Maze::LocalAppiumServer.expects(:`).with('appium -v').raises(Errno::ENOENT)
    assert_false(Maze::LocalAppiumServer.send(:appium_available?))
  end

  def test_appium_port_available?
    expected_port = '12345'
    response_string = ""
    Maze::LocalAppiumServer.expects(:`).with("netstat -vanp tcp | grep #{expected_port}").returns(response_string)
    assert(Maze::LocalAppiumServer.send(:appium_port_available?, expected_port))
  end

  def test_appium_port_not_available?
    expected_port = '12345'
    response_string = "something is using the port"
    Maze::LocalAppiumServer.expects(:`).with("netstat -vanp tcp | grep #{expected_port}").returns(response_string)
    assert_false(Maze::LocalAppiumServer.send(:appium_port_available?, expected_port))
  end

  def test_start_default
    # Setup mocks and expectations
    default_appium_command = "appium -a 0.0.0.0 -p 4723"
    thread_mock = mock('thread')
    stdin_mock = mock('stdin')
    stdout_mock = mock('stdout')
    pid = 12345

    # Corresponds to the two debug calls
    $logger.expects(:debug).with("Appium:#{pid}").twice

    # Expect Thread.new to be called, and allow block to process
    Thread.expects(:new).returns(thread_mock).yields

    # Expect PTY.spawn to be called, and allow block to process with mocks
    PTY.expects(:spawn).with(default_appium_command).yields(stdout_mock, stdin_mock, pid)

    # Expect stdout.each to be called, and yield "Foo" to trigger the logger
    stdout_mock.expects(:each).yields("Foo")

    # Ensure the at_exit is stubbed to avoid exit warnings
    Maze::LocalAppiumServer.stubs(:at_exit)

    # Ensure the sleep is stubbed to avoid delays
    Maze::LocalAppiumServer.expects(:sleep).with(2)

    # Expect appium_port_available? and appium_available? calls
    Maze::LocalAppiumServer.expects(:appium_port_available?).with('4723').returns(true)
    Maze::LocalAppiumServer.expects(:appium_available?).returns(true)

    Maze::LocalAppiumServer.start
    assert(Maze::LocalAppiumServer.running)
    assert_equal(Maze::LocalAppiumServer.instance_variable_get(:@pid), pid)
    assert_equal(Maze::LocalAppiumServer.instance_variable_get(:@appium_thread), thread_mock)
  end

  def test_start_overwritten_address_port
    overwritten_appium_command = "appium -a 1.2.3.4 -p 5678"
    thread_mock = mock('thread')
    Thread.expects(:new).returns(thread_mock).yields
    PTY.expects(:spawn).with(overwritten_appium_command)

    # Ensure the at_exit is stubbed to avoid exit warnings
    Maze::LocalAppiumServer.stubs(:at_exit)

    # Ensure the sleep is stubbed to avoid delays
    Maze::LocalAppiumServer.expects(:sleep).with(2)

    Maze::LocalAppiumServer.expects(:appium_port_available?).with('5678').returns(true)
    Maze::LocalAppiumServer.expects(:appium_available?).returns(true)

    Maze::LocalAppiumServer.start(address: '1.2.3.4', port: '5678')
  end

  def test_start_with_pid
    Maze::LocalAppiumServer.instance_variable_set(:@pid, '12345')

    Thread.expects(:new).never

    Maze::LocalAppiumServer.start
  end

  def test_start_port_unavailable
    $logger.expects(:warn).with('Requested appium port:4723 is in use. Aborting built-in appium server launch')

    Thread.expects(:new).never

    Maze::LocalAppiumServer.expects(:appium_port_available?).with('4723').returns(false)

    Maze::LocalAppiumServer.start
  end

  def test_start_appium_unavailable
    $logger.expects(:warn).with('Appium is unavailable to be started from the command line. Install using `npm i -g appium`')

    Thread.expects(:new).never

    Maze::LocalAppiumServer.expects(:appium_port_available?).with('4723').returns(true)
    Maze::LocalAppiumServer.expects(:appium_available?).returns(false)

    Maze::LocalAppiumServer.start
  end

  def test_stop_default
    $logger.expects(:debug).never
    Maze::LocalAppiumServer.stop
  end

  def test_stop_with_pid
    thread_mock = mock('thread')
    pid = 12345
    Maze::LocalAppiumServer.instance_variable_set(:@pid, pid)
    Maze::LocalAppiumServer.instance_variable_set(:@appium_thread, thread_mock)

    thread_mock.expects(:join)
    $logger.expects(:debug).with("Appium:#{pid}")
    Process.expects(:kill).with('INT', pid)

    Maze::LocalAppiumServer.stop

    assert_nil(Maze::LocalAppiumServer.instance_variable_get(:@pid))
    assert_nil(Maze::LocalAppiumServer.instance_variable_get(:@appium_thread))
  end
end