# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/options/option_parser'
require_relative '../../lib/options/option_validator'

# Tests the options parser and validator together.
class OptionsTest < Test::Unit::TestCase

  def setup
    @validator = Maze::OptionValidator.new
  end

  def test_invalid_farm
    args = %w[--farm=nope]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal "--farm must be either 'bs' or 'local' if provided", errors[0]
  end

  def test_valid_browser_stack_options
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=ANDROID_6_0]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_browser_stack_invalid_device
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=MADE_UP]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match 'Device type \'MADE_UP\' unknown on BrowserStack.  Must be one of', errors[0]
  end

  def test_browser_stack_missing_device
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--device must be specified', errors[0]
  end

  def test_browser_stack_missing_username
    args = %w[--farm=bs --app=my_app.apk --access-key=key --device=ANDROID_6_0]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--username must be specified', errors[0]
  end

  def test_browser_stack_missing_access_key
    args = %w[--farm=bs --app=my_app.apk --username=user --device=ANDROID_6_0]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--access-key must be specified', errors[0]
  end

  def test_browser_stack_missing_app
    args = %w[--farm=bs --username=user --access-key=key --device=ANDROID_6_0]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--app must be specified', errors[0]
  end

  def test_browser_stack_missing_many
    args = %w[--farm=bs]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 4, errors.length
    assert_equal '--app must be specified', errors[0]
    assert_equal '--device must be specified', errors[1]
    assert_equal '--username must be specified', errors[2]
    assert_equal '--access-key must be specified', errors[3]
  end

  def test_valid_local_options
    args = %w[--farm=local --app=my_app --os-version=8 --os=android]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_local_missing_os
    args = %w[--farm=local --app=my_app --os-version=8]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--os must be specified', errors[0]
  end

  def test_local_invalid_os_version
    args = %w[--farm=local --app=my_app --os-version=ZZZ --os=android]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_match '--os-version must be a valid version matching', errors[0]
  end

  def test_local_missing_os_version
    args = %w[--farm=local --app=my_app --os=android]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--os-version must be specified', errors[0]
  end

  def test_local_missing_app
    args = %w[--farm=local --os-version=8 --os=android]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--app must be specified', errors[0]
  end

  def test_valid_local_ios_options
    args = %w[--farm=local --app=my_app --os-version=8 --os=ios --apple-team-id=ABC --udid=123]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_empty errors
  end

  def test_local_ios_missing_team_id
    args = %w[--farm=local --app=my_app --os-version=8 --os=ios --udid=123]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--apple-team-id must be specified for iOS', errors[0]
  end

  def test_local_ios_missing_udid
    args = %w[--farm=local --app=my_app --os-version=8 --os=ios --apple-team-id=ABC]
    options = Maze::OptionParser.parse args
    errors = @validator.validate options

    assert_equal 1, errors.length
    assert_equal '--udid must be specified for iOS', errors[0]
  end
end
