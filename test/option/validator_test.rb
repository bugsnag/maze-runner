# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/option/parser'
require_relative '../../lib/maze/option/validator'

# Tests the options parser and validator together.
class ValidatorTest < Test::Unit::TestCase

  def setup
    @validator = Maze::Option::Validator.new
    # Prevent environment confusing tests
    ENV.delete('MAZE_BS_LOCAL')
    ENV.delete('MAZE_DEVICE_FARM_USERNAME')
    ENV.delete('MAZE_DEVICE_FARM_ACCESS_KEY')
    ENV.delete('MAZE_APPLE_TEAM_ID')
  end

  def test_invalid_farm
    args = %w[--farm=nope]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal "--farm must be either 'bs' or 'local' if provided", errors[0]
  end

  def test_valid_browser_stack_options
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=ANDROID_6_0]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_browser_stack_invalid_device
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=MADE_UP]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    puts errors
    assert_equal 1, errors.length
    assert_match 'Device type \'MADE_UP\' unknown on BrowserStack.  Must be one of', errors[0]
  end

  def test_browser_stack_invalid_browser
    args = %w[--farm=bs --username=user --access-key=key --browser=MADE_UP]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    puts errors
    assert_equal 1, errors.length
    assert_match 'Browser type \'MADE_UP\' unknown on BrowserStack.  Must be one of', errors[0]
  end

  def test_browser_stack_missing_device
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal 'Either --browser or --device must be specified', errors[0]
  end

  def test_browser_stack_missing_app
    args = %w[--farm=bs --username=user --access-key=key --device=ANDROID_6_0]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--app must be provided when running on a device', errors[0]
  end

  def test_valid_local_options
    args = %w[--farm=local --app=my_app --os-version=8 --os=android]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_local_invalid_os
    args = %w[--farm=local --app=my_app --os=invalid --os-version=8]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal 'os must be android, ios or macos', errors[0]
  end

  def test_local_missing_os
    args = %w[--farm=local --app=my_app --os-version=8]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--os must be specified', errors[0]
  end

  def test_local_invalid_os_version
    args = %w[--farm=local --app=my_app --os-version=ZZZ --os=android]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match '--os-version must be a valid version matching', errors[0]
  end

  def test_local_missing_os_version
    args = %w[--farm=local --app=my_app --os=android]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--os-version must be specified', errors[0]
  end

  def test_local_missing_app
    args = %w[--farm=local --os-version=8 --os=android]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--app must be specified', errors[0]
  end

  def test_valid_local_ios_options
    args = %w[--farm=local --app=my_app --os-version=8 --os=ios --apple-team-id=ABC --udid=123]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_local_ios_missing_udid
    args = %w[--farm=local --app=my_app --os-version=8 --os=ios --apple-team-id=ABC]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--udid must be specified for iOS', errors[0]
  end

  def test_valid_capabilities
    args = %w[--capabilities={"cap":"ability"}]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_invalid_capabilities
    args = %w[--capabilities={"cap":ability"}]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--capabilities must be valid JSON (given {"cap":ability"})', errors[0]
  end
end
