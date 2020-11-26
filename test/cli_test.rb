# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/features/support/interactive_cli'

class InteractiveCLITest < Test::Unit::TestCase

  def start_logger_mock
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock.stubs(:debug)
    logger_mock
  end

  def test_default_initialization
    start_logger_mock

    # Capture and prevent the shell starting on a secondary thread
    InteractiveCLI.any_instance.expects(:start_threaded_shell).with('/bin/sh')

    # Create the cli and verify class variables
    cli = InteractiveCLI.new
    assert_equal(cli.stdout_lines, [])
    assert_equal(cli.stderr_lines, [])
    assert_equal(cli.instance_variable_get(:@env), {})
    assert_equal(cli.instance_variable_get(:@stop_command), 'exit')
    assert_nil(cli.last_exit_code)
    assert_nil(cli.pid)
    assert_equal(cli.current_buffer, '')
    assert_false(cli.running?)
    assert_false(cli.run_command('foo'))

    Open3.expects(:popen3).with({}, '/bin/sh')
    cli.send(:start_shell, '/bin/sh')
  end

  def test_overridden_initialization
    start_logger_mock
    new_shell_cmd = '/bin/zsh'
    environment = {
      'foo': 'bar'
    }
    stop_command = 'stop_me_please'

    # Capture and prevent the shell starting on a secondary thread
    InteractiveCLI.any_instance.expects(:start_threaded_shell).with(new_shell_cmd)

    # Create the cli and verify class variables
    cli = InteractiveCLI.new(environment, new_shell_cmd, stop_command)
    assert_equal(cli.stdout_lines, [])
    assert_equal(cli.stderr_lines, [])
    assert_equal(cli.instance_variable_get(:@env), environment)
    assert_equal(cli.instance_variable_get(:@stop_command), stop_command)
    assert_nil(cli.last_exit_code)
    assert_nil(cli.pid)
    assert_equal(cli.current_buffer, '')
    assert_false(cli.running?)
    assert_false(cli.run_command('foo'))

    Open3.expects(:popen3).with(environment, new_shell_cmd)
    # Bypass the `private` modifier to call the start shell method directly
    cli.send(:start_shell, new_shell_cmd)
  end
end
