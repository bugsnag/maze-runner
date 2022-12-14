# frozen_string_literal: true

require 'net/http'
require 'json'
require 'open3'
require 'test_helper'
require_relative '../lib/maze/client/bs_client_utils'
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
    Kernel.stubs(:sleep).with('duration')
    logger_mock = mock('logger')
    $logger = logger_mock
  end

  def test_upload_app_skip
    $logger.expects(:info).with("Using pre-uploaded app from #{TEST_APP_URL}")

    url = Maze::Client::BrowserStackClientUtils.upload_app USERNAME, ACCESS_KEY, TEST_APP_URL
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

    url = Maze::Client::BrowserStackClientUtils.upload_app USERNAME, ACCESS_KEY, APP
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_error
    $logger.expects(:info).with("Uploading app: #{APP}").times(10)
    $logger.expects(:error).with("Upload failed due to error: Useless error").times(10)
    $logger.expects(:info).with('Retrying upload in 60s').times(9)
    Kernel.expects(:sleep).with(60).times(9)

    File.expects(:new)&.with(APP, 'rb')&.returns('file')
    Maze::Helper.expects(:expand_path).with(APP).returns(APP)

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    json_response = JSON.dump(error: 'Useless error')
    response_mock = mock('response')
    response_mock.expects(:body).times(10).returns(json_response)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com',
                                    443,
                                    use_ssl: true)&.times(10).returns(response_mock)

    assert_raise(RuntimeError, 'Upload failed due to error: Error') do
      Maze::Client::BrowserStackClientUtils.upload_app USERNAME, ACCESS_KEY, APP
    end
  end

  def test_upload_app_retry_success

    $logger.expects(:info).with("Uploading app: #{APP}").times(3)

    # First attempt fails due to ReadTimeout
    $logger.expects(:error).with("Upload failed due to ReadTimeout").once
    $logger.expects(:info).with('Retrying upload in 60s')
    Kernel.expects(:sleep).with(60)

    # Second attempt fails due to invalid response
    $logger.expects(:error).with("Upload failed due to error: Useless error").once
    $logger.expects(:info).with('Retrying upload in 60s')
    Kernel.expects(:sleep).with(60)

    # Third attempt succeeds
    $logger.expects(:info).with("app uploaded to: #{TEST_APP_URL}").once
    $logger.expects(:info).with('You can use this url to avoid uploading the same app more than once.').once

    File.expects(:new)&.with(APP, 'rb')&.returns('file')

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    success_json_response = JSON.dump(app_url: TEST_APP_URL)
    error_json_response = JSON.dump(error: 'Useless error')
    response_mock = mock('response')
    response_mock.expects(:body).returns(error_json_response).then.returns(success_json_response).at_most(2)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com', 443, use_ssl: true)&.raises(Net::ReadTimeout.new)
             .then.returns(response_mock)
             .then.returns(response_mock).at_most(3)

    url = Maze::Client::BrowserStackClientUtils.upload_app USERNAME, ACCESS_KEY, APP
    assert_equal(TEST_APP_URL, url)
  end

  def test_upload_app_invalid_response
    $logger.expects(:info).with("Uploading app: #{APP}").times(10)
    $logger.expects(:error).with("Unexpected JSON response, received: gobbledygook").times(10)
    $logger.expects(:info).with('Retrying upload in 60s').times(9)
    Kernel.expects(:sleep).with(60).times(9)

    File.expects(:new)&.with(APP, 'rb')&.returns('file')

    post_mock = mock('request')
    post_mock.expects(:basic_auth).with(USERNAME, ACCESS_KEY)
    post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

    json_response = 'gobbledygook'
    response_mock = mock('response')
    response_mock.expects(:body).times(10).returns(json_response)

    uri = URI('https://api-cloud.browserstack.com/app-automate/upload')
    Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
    Net::HTTP.expects(:start)&.with('api-cloud.browserstack.com',
                                    443,
                                    use_ssl: true)&.times(10).returns(response_mock)

    assert_raise(RuntimeError, 'Upload failed due to error: Error') do
      Maze::Client::BrowserStackClientUtils.upload_app USERNAME, ACCESS_KEY, APP
    end
  end

  def test_start_tunnel
    $logger.expects(:info).with('Starting BrowserStack local tunnel').once

    command_options = "-d start --key #{ACCESS_KEY} --local-identifier #{LOCAL_ID} --force-local --only-automate --force"
    Maze::Runner.expects(:run_command)&.with("#{BS_LOCAL} #{command_options}")&.returns([['{"pid":123}']])
    $logger.expects(:info).with('BrowserStackLocal daemon running under pid 123').once

    Maze::Client::BrowserStackClientUtils.start_local_tunnel BS_LOCAL, LOCAL_ID, ACCESS_KEY
  end
end

