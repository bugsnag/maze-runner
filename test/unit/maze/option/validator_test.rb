# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../../lib/maze/client/appium/bs_devices'
require_relative '../../../../lib/maze/option/parser'
require_relative '../../../../lib/maze/option/validator'
require_relative '../../../../lib/maze/helper'

# Tests the options parser and validator together.
class ValidatorTest < Test::Unit::TestCase

  def setup
    @validator = Maze::Option::Validator.new
    # Prevent environment confusing tests
    ENV.delete('MAZE_APPLE_TEAM_ID')
    ENV.delete('MAZE_BS_LOCAL')
    ENV.delete('BROWSER_STACK_USERNAME')
    ENV.delete('BROWSER_STACK_ACCESS_KEY')
    ENV.delete('BITBAR_ACCESS_KEY')

    Maze::Helper.stubs(:expand_path).with('/BrowserStackLocal').returns('/BrowserStackLocal')
    Maze::Helper.stubs(:expand_path).with('my_app.apk').returns('my_app.apk')
    Maze::Helper.stubs(:expand_path).with(nil).returns(nil)
  end

  def test_invalid_farm
    args = %w[--farm=nope]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal "--farm must be 'bs', 'bb' or 'local' if provided", errors[0]
  end

  def test_bugsnag_repeater_api_key
    args = %w[--repeater-api-key=invalid]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal "--repeater-api-key must be set to a 32-character hex value", errors[0]
  end

  def test_hub_repeater_api_key
    args = %w[--hub-repeater-api-key=invalid]
    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal "--hub-repeater-api-key must be set to a 32-character hex value", errors[0]
  end

  def test_bitbar_invalid_browser
    args = %w[--farm=bb --username=user --access-key=key --browser=MADE_UP]

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match 'Browser types \'MADE_UP\' unknown on BitBar.  Must be one of', errors[0]
  end

  def test_bitbar_missing_browser_version
    args = %w[--farm=bb --username=user --access-key=key --browser=edge]

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match "--browser-version must be specified for browser 'edge'", errors[0]
  end

  def test_bitbar_browser_version
    args = %w[--farm=bb --username=user --access-key=key --browser=edge --browser-version=105]

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 0, errors.length
  end

  def test_valid_browser_stack_options
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=ANDROID_11]
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

    assert_equal 1, errors.length
    assert_match 'Device type \'MADE_UP\' unknown on BrowserStack.  Must be one of', errors[0]
  end

  def test_browser_stack_invalid_browser
    args = %w[--farm=bs --username=user --access-key=key --browser=MADE_UP]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)
    File.stubs(:exist?).with('my_app.apk').returns(true)

    options = Maze::Option::Parser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match 'Browser types \'MADE_UP\' unknown on BrowserStack.  Must be one of', errors[0]
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
    args = %w[--farm=bs --username=user --access-key=key --device=ANDROID_11]
    File.stubs(:exist?).with('/BrowserStackLocal').returns(true)

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
    assert_equal 'os must be android, ios, macos or windows', errors[0]
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

    assert_equal 0, errors.length
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

  def test_api_key_validation
    $logger = mock('logger')

    normal_args = %w[--repeater-api-key=12312312312312312312312312312312]
    
    normal_options = Maze::Option::Parser.parse normal_args
    normal_errors = @validator.validate normal_options
    assert_empty normal_errors
    
    $logger.expects(:warn).with("A repeater-api-key option was provided with an empty string. This won't be used during this test run")
    empty_args = %w[--repeater-api-key=]
    empty_options = Maze::Option::Parser.parse empty_args
    empty_errors = @validator.validate empty_options
    assert_empty empty_errors

    ENV['MAZE_REPEATER_API_KEY'] = '32132132132132132132132132132132'
    env_options = Maze::Option::Parser.parse []
    env_errors = @validator.validate env_options
    assert_empty env_errors
    ENV.delete('MAZE_REPEATER_API_KEY')

    $logger.expects(:warn).with("A repeater-api-key option was provided with an empty string. This won't be used during this test run")
    ENV['MAZE_REPEATER_API_KEY'] = ''
    empty_env_options = Maze::Option::Parser.parse []
    empty_env_errors = @validator.validate empty_env_options
    assert_empty empty_env_errors
    ENV.delete('MAZE_REPEATER_API_KEY')
  end
end
