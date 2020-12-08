# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/options/option'
require_relative '../../lib/options/option_parser'

# Tests the options parser and processor together (using only valid options and with no validator).
class OptionsParserTest < Test::Unit::TestCase
  def setup
    ENV.delete('MAZE_DEVICE_FARM_USERNAME')
    ENV.delete('MAZE_DEVICE_FARM_ACCESS_KEY')
    ENV.delete('MAZE_APPLE_TEAM_ID')
    ENV.delete('MAZE_UDID')
  end

  def test_default_values
    args = %w[]
    options = Maze::OptionParser.parse args

    # Common options
    assert_false(options[Maze::Option::SEPARATE_SESSIONS])
    assert_nil(options[Maze::Option::FARM])
    assert_nil(options[Maze::Option::APP])
    assert_false(options[Maze::Option::A11Y_LOCATOR])
    assert_false(options[Maze::Option::RESILIENT])
    assert_equal('{}', options[Maze::Option::CAPABILITIES])

    # BrowserStack-only options
    assert_equal('/BrowserStackLocal', options[Maze::Option::BS_LOCAL])
    assert_nil(options[Maze::Option::BS_DEVICE])
    assert_nil(options[Maze::Option::USERNAME])
    assert_nil(options[Maze::Option::ACCESS_KEY])
    assert_nil(options[Maze::Option::BS_APPIUM_VERSION])

    # Local-only options
    assert_nil(options[Maze::Option::OS])
    assert_nil(options[Maze::Option::OS_VERSION])
    assert_equal('http://localhost:4723/wd/hub', options[Maze::Option::APPIUM_SERVER])
    assert_nil(options[Maze::Option::APPLE_TEAM_ID])
    assert_nil(options[Maze::Option::UDID])
  end

  def test_overwritten_values
    args = %w[
      --separate-sessions=true
      --farm=ARG_FARM
      --app=ARG_APP
      --a11y-locator=true
      --resilient=true
      --capabilities=ARG_CAPABILITIES
      --bs-local=ARG_BS_LOCAL
      --device=ARG_DEVICE
      --username=ARG_USERNAME
      --access-key=ARG_ACCESS_KEY
      --appium-version=ARG_APPIUM_VERSION
      --os=ARG_OS
      --os-version=ARG_OS_VERSION
      --appium-server=ARG_APPIUM_SERVER
      --apple-team-id=ARG_APPLE_TEAM_ID
      --udid=ARG_UDID
    ]
    options = Maze::OptionParser.parse args

    # Common options
    assert_true(options[Maze::Option::SEPARATE_SESSIONS])
    assert_equal('ARG_FARM', options[Maze::Option::FARM])
    assert_equal('ARG_APP', options[Maze::Option::APP])
    assert_true(options[Maze::Option::A11Y_LOCATOR])
    assert_true(options[Maze::Option::RESILIENT])
    assert_equal('ARG_CAPABILITIES', options[Maze::Option::CAPABILITIES])

    # BrowserStack-only options
    assert_equal('ARG_BS_LOCAL', options[Maze::Option::BS_LOCAL])
    assert_equal('ARG_DEVICE', options[Maze::Option::BS_DEVICE])
    assert_equal('ARG_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ARG_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ARG_APPIUM_VERSION', options[Maze::Option::BS_APPIUM_VERSION])

    # Local-only options
    assert_equal('ARG_OS', options[Maze::Option::OS])
    assert_equal('ARG_OS_VERSION', options[Maze::Option::OS_VERSION])
    assert_equal('ARG_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_equal('ARG_APPLE_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ARG_UDID', options[Maze::Option::UDID])
  end

  def test_short_flags
    args = %w[
      -f SHORT_FARM
      -a SHORT_APP
      -r true
      -c SHORT_CAPABILITIES
      -u SHORT_USERNAME
      -p SHORT_ACCESS_KEY
    ]
    options = Maze::OptionParser.parse args

    # Common options
    assert_equal('SHORT_FARM', options[Maze::Option::FARM])
    assert_equal('SHORT_APP', options[Maze::Option::APP])
    assert_true(options[Maze::Option::RESILIENT])
    assert_equal('SHORT_CAPABILITIES', options[Maze::Option::CAPABILITIES])

    # BrowserStack-only options
    assert_equal('SHORT_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('SHORT_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
  end

  def test_environment_values
    ENV['MAZE_DEVICE_FARM_USERNAME'] = 'ENV_USERNAME'
    ENV['MAZE_DEVICE_FARM_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[]
    options = Maze::OptionParser.parse args

    # BrowserStack-only options
    assert_equal('ENV_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ENV_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])

    # Local-only options
    assert_equal('ENV_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ENV_UDID', options[Maze::Option::UDID])
  end

  def test_override_priority
    ENV['MAZE_DEVICE_FARM_USERNAME'] = 'ENV_USERNAME'
    ENV['MAZE_DEVICE_FARM_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[
      --username=ARG_USERNAME
      --access-key=ARG_ACCESS_KEY
      --apple-team-id=ARG_TEAM_ID
      --udid=ARG_UDID
    ]
    options = Maze::OptionParser.parse args

    # BrowserStack-only options
    assert_equal('ARG_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ARG_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])

    # Local-only options
    assert_equal('ARG_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ARG_UDID', options[Maze::Option::UDID])
  end
end
