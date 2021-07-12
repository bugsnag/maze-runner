# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/option'
require_relative '../../lib/maze/option/parser'

# Tests the options parser and processor together (using only valid options and with no validator).
class ParserTest < Test::Unit::TestCase
  def setup
    ENV.delete('BROWSER_STACK_USERNAME')
    ENV.delete('BROWSER_STACK_ACCESS_KEY')
    ENV.delete('BROWSER_STACK_BROWSERS_USERNAME')
    ENV.delete('BROWSER_STACK_BROWSERS_ACCESS_KEY')
    ENV.delete('BROWSER_STACK_DEVICES_USERNAME')
    ENV.delete('BROWSER_STACK_DEVICES_ACCESS_KEY')
    ENV.delete('SAUCE_LABS_USERNAME')
    ENV.delete('SAUCE_LABS_ACCESS_KEY')
    ENV.delete('CBT_USERNAME')
    ENV.delete('CBT_ACCESS_KEY')
    ENV.delete('MAZE_BS_LOCAL')
    ENV.delete('MAZE_SL_LOCAL')
    ENV.delete('MAZE_BB_LOCAL')
    ENV.delete('MAZE_APPIUM_SERVER')
    ENV.delete('MAZE_APPLE_TEAM_ID')
    ENV.delete('MAZE_UDID')
    ENV.delete('BITBAR_USERNAME')
    ENV.delete('BITBAR_ACCESS_KEY')
  end

  def test_default_values
    args = %w[]
    options = Maze::Option::Parser.parse args

    # Common options
    assert_false(options[Maze::Option::SEPARATE_SESSIONS])
    assert_nil(options[Maze::Option::FARM])
    assert_nil(options[Maze::Option::APP])
    assert_false(options[Maze::Option::A11Y_LOCATOR])
    assert_false(options[Maze::Option::RESILIENT])
    assert_equal('{}', options[Maze::Option::CAPABILITIES])

    # Device-farm-only options
    assert_equal('/BrowserStackLocal', options[Maze::Option::BS_LOCAL])
    assert_equal([], options[Maze::Option::DEVICE])
    assert_nil(options[Maze::Option::BROWSER])
    assert_nil(options[Maze::Option::USERNAME])
    assert_nil(options[Maze::Option::ACCESS_KEY])
    assert_nil(options[Maze::Option::APPIUM_VERSION])

    # Local-only options
    assert_nil(options[Maze::Option::OS])
    assert_nil(options[Maze::Option::OS_VERSION])
    assert_equal('http://localhost:4723/wd/hub', options[Maze::Option::APPIUM_SERVER])
    assert_nil(options[Maze::Option::APPLE_TEAM_ID])
    assert_nil(options[Maze::Option::UDID])

    # Logging options
    assert_true(options[Maze::Option::FILE_LOG])
    assert_false(options[Maze::Option::LOG_REQUESTS])
  end

  def test_buildkite_default_values
    ENV['BUILDKITE'] = "true"

    args = %w[]
    options = Maze::Option::Parser.parse args

    # Logging options
    assert_false(options[Maze::Option::LOG_REQUESTS])
  end

  def test_overwritten_values
    args = %w[
      --separate-sessions
      --farm=ARG_FARM
      --app=ARG_APP
      --a11y-locator
      --resilient
      --capabilities=ARG_CAPABILITIES
      --bs-local=ARG_BS_LOCAL
      --device=ARG_DEVICE
      --browser=ARG_BROWSER
      --username=ARG_USERNAME
      --access-key=ARG_ACCESS_KEY
      --appium-version=ARG_APPIUM_VERSION
      --os=ARG_OS
      --os-version=ARG_OS_VERSION
      --appium-server=ARG_APPIUM_SERVER
      --no-start-appium
      --apple-team-id=ARG_APPLE_TEAM_ID
      --udid=ARG_UDID
      --log-requests
      --no-file-log
    ]
    options = Maze::Option::Parser.parse args

    # Common options
    assert_true(options[Maze::Option::SEPARATE_SESSIONS])
    assert_equal('ARG_FARM', options[Maze::Option::FARM])
    assert_equal('ARG_APP', options[Maze::Option::APP])
    assert_true(options[Maze::Option::A11Y_LOCATOR])
    assert_true(options[Maze::Option::RESILIENT])
    assert_equal('ARG_CAPABILITIES', options[Maze::Option::CAPABILITIES])

    # Device-farm-only options
    assert_equal('ARG_BS_LOCAL', options[Maze::Option::BS_LOCAL])
    assert_equal(['ARG_DEVICE'], options[Maze::Option::DEVICE])
    assert_equal('ARG_BROWSER', options[Maze::Option::BROWSER])
    assert_equal('ARG_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ARG_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ARG_APPIUM_VERSION', options[Maze::Option::APPIUM_VERSION])

    # Local-only options
    assert_equal('ARG_OS', options[Maze::Option::OS])
    assert_equal('ARG_OS_VERSION', options[Maze::Option::OS_VERSION])
    assert_equal('ARG_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_false(options[Maze::Option::START_APPIUM])
    assert_equal('ARG_APPLE_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ARG_UDID', options[Maze::Option::UDID])

    # Logging options
    assert_false(options[Maze::Option::FILE_LOG])
    assert_true(options[Maze::Option::LOG_REQUESTS])
  end

  def test_environment_values
    ENV['BROWSER_STACK_USERNAME'] = 'ENV_USERNAME'
    ENV['BROWSER_STACK_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['MAZE_BS_LOCAL'] = 'ENV_BS_LOCAL'
    ENV['MAZE_SL_LOCAL'] = 'ENV_SL_LOCAL'
    ENV['MAZE_APPIUM_SERVER'] = 'ENV_APPIUM_SERVER'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[--farm=bs]
    options = Maze::Option::Parser.parse args

    # BrowserStack-only options
    assert_equal('ENV_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ENV_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ENV_BS_LOCAL', options[Maze::Option::BS_LOCAL])

    # Local-only options
    assert_equal('ENV_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_equal('ENV_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ENV_UDID', options[Maze::Option::UDID])
  end

  def test_environment_value_browsers
    ENV['BROWSER_STACK_BROWSERS_USERNAME'] = 'ENV_USERNAME'
    ENV['BROWSER_STACK_BROWSERS_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['BROWSER_STACK_USERNAME'] = 'DO_NOT_USE'
    ENV['BROWSER_STACK_ACCESS_KEY'] = 'DO_NOT_USE'
    ENV['MAZE_BS_LOCAL'] = 'ENV_BS_LOCAL'
    ENV['MAZE_SL_LOCAL'] = 'ENV_SL_LOCAL'
    ENV['MAZE_APPIUM_SERVER'] = 'ENV_APPIUM_SERVER'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[--farm=bs --browser=something]
    options = Maze::Option::Parser.parse args

    # BrowserStack-only options
    assert_equal('ENV_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ENV_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ENV_BS_LOCAL', options[Maze::Option::BS_LOCAL])

    # Local-only options
    assert_equal('ENV_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_equal('ENV_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ENV_UDID', options[Maze::Option::UDID])
  end

  def test_environment_value_devices
    ENV['BROWSER_STACK_DEVICES_USERNAME'] = 'ENV_USERNAME'
    ENV['BROWSER_STACK_DEVICES_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['BROWSER_STACK_USERNAME'] = 'DO_NOT_USE'
    ENV['BROWSER_STACK_ACCESS_KEY'] = 'DO_NOT_USE'
    ENV['MAZE_BS_LOCAL'] = 'ENV_BS_LOCAL'
    ENV['MAZE_SL_LOCAL'] = 'ENV_SL_LOCAL'
    ENV['MAZE_APPIUM_SERVER'] = 'ENV_APPIUM_SERVER'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[--farm=bs --device=something]
    options = Maze::Option::Parser.parse args

    # BrowserStack-only options
    assert_equal('ENV_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ENV_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ENV_BS_LOCAL', options[Maze::Option::BS_LOCAL])

    # Local-only options
    assert_equal('ENV_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_equal('ENV_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ENV_UDID', options[Maze::Option::UDID])
  end

  def test_override_priority
    ENV['SAUCE_LABS_USERNAME'] = 'ENV_USERNAME'
    ENV['SAUCE_LABS_ACCESS_KEY'] = 'ENV_ACCESS_KEY'
    ENV['MAZE_SL_LOCAL'] = 'ENV_BS_LOCAL'
    ENV['MAZE_APPIUM_SERVER'] = 'ENV_APPIUM_SERVER'
    ENV['MAZE_APPLE_TEAM_ID'] = 'ENV_TEAM_ID'
    ENV['MAZE_UDID'] = 'ENV_UDID'

    args = %w[
      --farm=sl
      --username=ARG_USERNAME
      --access-key=ARG_ACCESS_KEY
      --sl-local=ARG_SL_LOCAL
      --appium-server=ARG_APPIUM_SERVER
      --apple-team-id=ARG_TEAM_ID
      --udid=ARG_UDID
    ]
    options = Maze::Option::Parser.parse args

    # SauceLabs-only options
    assert_equal('ARG_USERNAME', options[Maze::Option::USERNAME])
    assert_equal('ARG_ACCESS_KEY', options[Maze::Option::ACCESS_KEY])
    assert_equal('ARG_SL_LOCAL', options[Maze::Option::SL_LOCAL])

    # Local-only options
    assert_equal('ARG_APPIUM_SERVER', options[Maze::Option::APPIUM_SERVER])
    assert_equal('ARG_TEAM_ID', options[Maze::Option::APPLE_TEAM_ID])
    assert_equal('ARG_UDID', options[Maze::Option::UDID])
  end
end
