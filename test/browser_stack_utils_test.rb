# frozen_string_literal: true

require 'json'
require 'open3'
require 'test_helper'
require_relative '../lib/maze/browser_stack_utils'

class BrowserStackUtilsTest < Test::Unit::TestCase

  ACCESS_KEY = 'access_key'
  APP = '/app/location'
  BS_LOCAL = '/home/BrowserStackLocal'
  LOCAL_ID = 'abcde'
  TEST_APP_URL = 'bs://1234567890abcdef'
  USERNAME = 'username'

  def setup
    logger_mock = mock('logger')
    $logger = logger_mock
  end

  def test_upload_app_skip
    $logger.expects(:info).with("Using pre-uploaded app from #{TEST_APP_URL}")

    url = Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, TEST_APP_URL
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_success
    $logger.expects(:info).with("app uploaded to: #{TEST_APP_URL}").once
    $logger.expects(:info).with('You can use this url to avoid uploading the same app more than once.').once

    json_response = JSON.dump(app_url: TEST_APP_URL)
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP}")
    Maze::BrowserStackUtils.stubs(:`).with(expected_command).returns(json_response)
    url = Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_error
    json_response = JSON.dump(
      error: 'Error'
    )
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP}")
    Maze::BrowserStackUtils.stubs(:`).with(expected_command).returns(json_response)
    assert_raise(RuntimeError, 'BrowserStack upload failed due to error: Error') do
      Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP
    end
  end

  def test_start_tunnel
    $logger.expects(:info).with('Starting BrowserStack local tunnel').once

    command_options = "-d start --key #{ACCESS_KEY} --local-identifier #{LOCAL_ID} --force-local --only-automate --force"
    waiter = mock('Process::Waiter', value: mock('Process::Status'))
    Open3.expects(:popen2).with("#{BS_LOCAL} #{command_options}").yields(mock('stdin'), mock('stdout'), waiter)

    Maze::BrowserStackUtils.start_local_tunnel BS_LOCAL, LOCAL_ID, ACCESS_KEY
  end
end
