# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/maze/errors'
require_relative '../../lib/maze/hooks/error_code_hook'

class ErrorCodeHookTest < Test::Unit::TestCase

  def setup
    Maze::Hooks::ErrorCodeHook.instance_variable_set(:@registered, false)
  end

  def test_install_hook_success
    Maze::Hooks::ErrorCodeHook.expects(:at_exit).with_block_given

    Maze::Hooks::ErrorCodeHook.register_exit_code_hook

    assert(Maze::Hooks::ErrorCodeHook.instance_variable_get(:@registered))
  end

  def test_hook_unique
    Maze::Hooks::ErrorCodeHook.expects(:at_exit).once.with_block_given

    Maze::Hooks::ErrorCodeHook.register_exit_code_hook
    Maze::Hooks::ErrorCodeHook.register_exit_code_hook

    assert(Maze::Hooks::ErrorCodeHook.instance_variable_get(:@registered))
  end

  def test_exit_hook_default
    # In normal circumstances we don't override the error code
    Maze::Hooks::ErrorCodeHook.expects(:exit).never
    Maze::Hooks::ErrorCodeHook.send :exit_hook
  end

  def test_user_specified_error_code
    Maze::Hooks::ErrorCodeHook.exit_code = 1234
    Maze::Hooks::ErrorCodeHook.expects(:exit).once.with(1234)
    Maze::Hooks::ErrorCodeHook.send :exit_hook
  end

  def test_last_test_error_class_error_code
    Maze::Hooks::ErrorCodeHook.last_test_error_class = ::Selenium::WebDriver::Error::UnknownError
    Maze::Hooks::ErrorCodeHook.expects(:exit).once.with(10)
    Maze::Hooks::ErrorCodeHook.send :exit_hook
  end
end

