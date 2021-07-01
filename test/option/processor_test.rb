# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/maze/option/parser'
require_relative '../../lib/maze/option/processor'
require_relative '../../lib/maze/configuration'
require_relative '../../lib/maze/helper'

# Tests the options parser and processor together (using only valid options and with no validator).
class ProcessorTest < Test::Unit::TestCase
  def setup
    ENV.delete('BUILDKITE')
    ENV.delete('MAZE_BS_LOCAL')
    ENV.delete('MAZE_SL_LOCAL')
    ENV.delete('BROWSER_STACK_USERNAME')
    ENV.delete('BROWSER_STACK_ACCESS_KEY')
    ENV.delete('SAUCE_LABS_USERNAME')
    ENV.delete('SAUCE_LABS_ACCESS_KEY')
    ENV.delete('BITBAR_API_KEY')

    Maze::Helper.stubs(:expand_path).with('/BrowserStackLocal').returns('/BrowserStackLocal')
  end

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
    assert_equal 'ANDROID_6_0', config.device
    assert_equal 6, config.os_version
    assert_equal :id, config.locator
    assert_equal 'http://user:key@hub-cloud.browserstack.com/wd/hub', config.appium_server_url
  end

  def test_populate_bs_config_resilient
    args = %w[--farm=bs --app=my_app.apk --username=b --access-key=c --device=ANDROID_6_0 --resilient --a11y-locator]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_false config.appium_session_isolation
    assert_true config.resilient
    assert_equal :accessibility_id, config.locator
  end

  def test_populate_local_config
    args = %w[--farm=local --app=my_app.apk --os=ios --os-version=7.1 --apple-team-id=ABC --udid=123 \
              --bind-address=1.2.3.4 --port=1234 --no-start-appium --document-server-root=root \
              --document-server-bind-address=5.6.7.8 --document-server-port=5678]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_equal :local, config.farm
    assert_equal 'my_app.apk', config.app
    assert_equal 'ios', config.os
    assert_equal 7.1, config.os_version
    assert_equal 'ABC', config.apple_team_id
    assert_equal '123', config.device_id
    assert_equal '1.2.3.4', config.bind_address
    assert_equal 1234, config.port
    assert_equal 'root', config.document_server_root
    assert_equal '5.6.7.8', config.document_server_bind_address
    assert_equal 5678, config.document_server_port
    assert_false config.start_appium
  end

  def test_logger_options
    args = %w[--no-file-log --log-requests --always-log]
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_false config.file_log
    assert_true config.log_requests
    assert_true config.always_log
  end

  def test_default_options
    args = []
    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    assert_equal nil, config.bind_address
    assert_equal 9339, config.port
    assert_equal nil, config.document_server_root
    assert_equal nil, config.document_server_bind_address
    assert_equal 9340, config.document_server_port

    assert_false config.appium_session_isolation
    assert_equal :id, config.locator
    assert_false config.resilient
    assert_nil config.capabilities

    assert_true config.file_log
    assert_false config.log_requests
    assert_false config.always_log
  end

  def test_filename_options
    args = %w[--app=@filename]

    File.stubs(:read).with('filename').returns('file-contents')

    options = Maze::Option::Parser.parse args
    config = Maze::Configuration.new
    Maze::Option::Processor.populate config, options

    # Local-only options
    assert_equal('file-contents', config.app)
  end
end
