# frozen_string_literal: true

require 'test_helper'
require 'pty'
require_relative '../lib/features/support/local_appium_server'

class LocalAppiumServerTest < Test::Unit::TestCase

  def setup
    logger_mock = mock('logger')
    $logger = logger_mock

    # Reset everything to default
    LocalAppiumServer.instance_variable_set(:@pid, nil)
    LocalAppiumServer.instance_variable_set(:@appium_thread, nil)
  end

  def test_running_default
    assert_false(LocalAppiumServer.running)
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
    LocalAppiumServer.stubs(:at_exit)

    LocalAppiumServer.start
    assert(LocalAppiumServer.running)
    assert_equal(LocalAppiumServer.instance_variable_get(:@pid), pid)
    assert_equal(LocalAppiumServer.instance_variable_get(:@appium_thread), thread_mock)
  end

  def test_stop_default
    $logger.expects(:debug).never
    LocalAppiumServer.stop
  end

  def test_start_overwritten_address_port
    overwritten_appium_command = "appium -a 1.2.3.4 -p 5678"
    thread_mock = mock('thread')
    Thread.expects(:new).returns(thread_mock).yields
    PTY.expects(:spawn).with(overwritten_appium_command)

    # Ensure the at_exit is stubbed to avoid exit warnings
    LocalAppiumServer.stubs(:at_exit)

    LocalAppiumServer.start(address: '1.2.3.4', port: '5678')
  end

  def test_stop_with_pid
    thread_mock = mock('thread')
    pid = 12345
    LocalAppiumServer.instance_variable_set(:@pid, pid)
    LocalAppiumServer.instance_variable_set(:@appium_thread, thread_mock)

    thread_mock.expects(:join)
    $logger.expects(:debug).with("Appium:#{pid}")
    Process.expects(:kill).with('INT', pid)

    LocalAppiumServer.stop

    assert_nil(LocalAppiumServer.instance_variable_get(:@pid))
    assert_nil(LocalAppiumServer.instance_variable_get(:@appium_thread))
  end
end