# frozen_string_literal: true

require 'json'
require 'test_helper'
require_relative '../lib/features/support/browser_stack_utils'

class BrowserStackUtilsTest < Test::Unit::TestCase

  TEST_APP_URL = 'bs://1234567890abcdef'
  USERNAME = 'username'
  ACCESS_KEY = 'access_key'
  APP_LOCATION = '/app/location'

  def test_upload_app_skip
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock.expects(:info).with("Skipping upload for pre-uploaded app #{TEST_APP_URL}")

    url = BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, TEST_APP_URL
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_success
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock.expects(:info).with("app uploaded to: #{TEST_APP_URL}").once
    logger_mock.expects(:info).with('You can use this url to avoid uploading the same app more than once.').once

    json_response = JSON.dump(app_url: TEST_APP_URL)
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    BrowserStackUtils.stubs(:`).with(expected_command).returns(json_response)
    url = BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP_LOCATION
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_error
    json_response = JSON.dump(
      error: 'Error'
    )
    expected_command = %(curl -u "#{USERNAME}:#{ACCESS_KEY}" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@#{APP_LOCATION}")
    BrowserStackUtils.stubs(:`).with(expected_command).returns(json_response)
    assert_raise(RuntimeError, 'BrowserStack upload failed due to error: Error') do
      BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP_LOCATION
    end
  end

end
