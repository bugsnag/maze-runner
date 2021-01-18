# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/option/parser'
require_relative '../../lib/maze/option/processor'
require_relative '../../lib/maze/configuration'

# Tests the options parser and processor together (using only valid options and with no validator).
class ProcessorTest < Test::Unit::TestCase
  def test_populate_bs_config_separate
    args = %w[--farm=bs --app=my_app.apk --username=user --access-key=key --device=ANDROID_6_0 --separate-sessions]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_true config.appium_session_isolation
    assert_false config.resilient
    assert_equal :bs, config.farm
    assert_equal 'my_app.apk', config.app
    assert_equal 'user', config.username
    assert_equal 'key', config.access_key
    assert_equal 'ANDROID_6_0', config.bs_device
    assert_equal 6, config.os_version
    assert_equal :id, config.locator
    assert_equal 'http://user:key@hub-cloud.browserstack.com/wd/hub', config.appium_server_url
  end

  def test_populate_bs_config_resilient
    args = %w[--farm=bs --app=a --username=b --access-key=c --device=ANDROID_6_0 --resilient --a11y-locator]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_false config.appium_session_isolation
    assert_true config.resilient
    assert_equal :accessibility_id, config.locator
  end

  def test_populate_local_config
    args = %w[--farm=local --app=my_app.ipa --os=ios --os-version=7.1 --apple-team-id=ABC --udid=123]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_equal :local, config.farm
    assert_equal 'my_app.ipa', config.app
    assert_equal 'ios', config.os
    assert_equal 7.1, config.os_version
    assert_equal 'ABC', config.apple_team_id
    assert_equal '123', config.device_id
  end
end
