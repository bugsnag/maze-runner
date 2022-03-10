# frozen_string_literal: true

require 'net/http'
require 'json'
require 'open3'
require 'test_helper'
require_relative '../lib/maze/browser_stack_utils'
require_relative '../lib/maze/helper'
require_relative '../lib/maze/runner'

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
    $logger.expects(:info).with("Uploading app: #{APP}").once
    $logger.expects(:info).with("app uploaded to: #{TEST_APP_URL}").once
    $logger.expects(:info).with('You can use this url to avoid uploading the same app more than once.').once

    File.expects(:new)&.with(APP, 'rb')&.returns('file')

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    json_response = JSON.dump(app_url: TEST_APP_URL)
    response_mock = mock('response')
    response_mock.expects(:body).returns(json_response)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com',
                                    443,
                                    use_ssl: true)&.returns(response_mock)

    url = Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_error
    $logger.expects(:info).with("Uploading app: #{APP}").once
    $logger.expects(:error).with("Upload failed due to error: Useless error").at_most(3)

    File.expects(:new)&.with(APP, 'rb')&.returns('file')
    Maze::Helper.expects(:expand_path).with(APP).returns(APP)

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    json_response = JSON.dump(error: 'Useless error')
    response_mock = mock('response')
    response_mock.expects(:body).at_most(3).returns(json_response)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com',
                                    443,
                                    use_ssl: true)&.at_most(3).returns(response_mock)

    assert_raise(RuntimeError, 'Upload failed due to error: Error') do
      Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP
    end
  end

  def test_upload_app_invalid_response
    $logger.expects(:info).with("Uploading app: #{APP}").once
    $logger.expects(:error).with("Error: expected JSON response, received: gobbledygook").at_most(3)

    File.expects(:new)&.with(APP, 'rb')&.returns('file')

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    json_response = 'gobbledygook'
    response_mock = mock('response')
    response_mock.expects(:body).at_most(3).returns(json_response)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com',
                                    443,
                                    use_ssl: true)&.at_most(3).returns(response_mock)

    assert_raise(RuntimeError, 'Upload failed due to error: Error') do
      Maze::BrowserStackUtils.upload_app USERNAME, ACCESS_KEY, APP
    end
  end

  def test_start_tunnel
    $logger.expects(:info).with('Starting BrowserStack local tunnel').once

    command_options = "-d start --key #{ACCESS_KEY} --local-identifier #{LOCAL_ID} --force-local --only-automate --force"
    Maze::Runner.expects(:run_command)&.with("#{BS_LOCAL} #{command_options}")&.returns([['{"pid":123}']])
    $logger.expects(:info).with('BrowserStackLocal daemon running under pid 123').once

    Maze::BrowserStackUtils.start_local_tunnel BS_LOCAL, LOCAL_ID, ACCESS_KEY
  end
end
