# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../../lib/maze'
require_relative '../../../../lib/maze/helper'
require_relative '../../../../lib/maze/client/bb_client_utils'
require_relative '../../../../lib/maze/runner'

module Maze
  module Client
    class BitBarClientUtilsTest < Test::Unit::TestCase

      API_KEY = 'bitbar_api_key'
      APP_ID = '1234567890'
      APP_PATH = '/app/location'
      GIT_COMMAND = 'git rev-parse --show-toplevel'
      REPO_NAME = 'repo-name'
      REPO_PATH = "/some/path/to/#{REPO_NAME}"
      UNKNOWN_PROJECT = 'Unknown'
      UUID = '12345'

      def setup
        ENV.delete('BUILDKITE')
        ENV.delete('BUILDKITE_BUILD_NUMBER')
        ENV.delete('BUILDKITE_LABEL')
        ENV.delete('BUILDKITE_PIPELINE_SLUG')
        ENV.delete('BUILDKITE_RETRY_COUNT')

        logger_mock = mock('logger')
        $logger = logger_mock

        Maze.run_uuid = UUID
      end

      def test_upload_app_skip
        $logger.expects(:info).with("Using pre-uploaded app with ID #{APP_ID}")

        id = Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_ID
        assert_equal(APP_ID, id)
      end

      def test_upload_app_success
        $logger.expects(:info).with("Uploading app: #{APP_PATH}").once
        $logger.expects(:info).with("Uploaded app ID: #{APP_ID}").once
        $logger.expects(:info).with('You can use this ID to avoid uploading the same app more than once.').once

        File.expects(:new)&.with(APP_PATH, 'rb')&.returns('file')
        Maze::Helper.expects(:expand_path).with(APP_PATH).returns(APP_PATH)

        post_mock = mock('request')
        post_mock.expects(:basic_auth).with(API_KEY, '')
        post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

        json_response = JSON.dump(id: APP_ID)
        response_mock = mock('response')
        response_mock.expects(:body).returns(json_response)

        uri = URI('https://cloud.bitbar.com/api/me/files')
        Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
        Net::HTTP.expects(:start)&.with('cloud.bitbar.com',
                                        443,
                                        use_ssl: true)&.returns(response_mock)

        id = Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_PATH
        assert_equal(APP_ID, id)
      end

      def test_upload_app_error
        $logger.expects(:info).with("Uploading app: #{APP_PATH}").once

        File.expects(:new)&.with(APP_PATH, 'rb')&.returns('file')
        Maze::Helper.expects(:expand_path).with(APP_PATH).returns(APP_PATH)

        post_mock = mock('request')
        post_mock.expects(:basic_auth).with(API_KEY, '')
        post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

        json_response = JSON.dump(error: 'Useless error')
        response_mock = mock('response')
        response_mock.expects(:body).returns(json_response)

        uri = URI('https://cloud.bitbar.com/api/me/files')
        Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
        Net::HTTP.expects(:start)&.with('cloud.bitbar.com',
                                        443,
                                        use_ssl: true)&.returns(response_mock)

        $logger.expects(:error).with("Unexpected response body: #{JSON.parse json_response}").once
        $logger.expects(:error).with("App upload to BitBar failed after 1 attempts").once
        assert_raise(RuntimeError, 'Unexpected response body: #{JSON.parse json_response}') do
          Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_PATH, nil, 1
        end
      end

      def test_upload_app_invalid_response
        $logger.expects(:info).with("Uploading app: #{APP_PATH}").once

        File.expects(:new)&.with(APP_PATH, 'rb')&.returns('file')
        Maze::Helper.expects(:expand_path).with(APP_PATH).returns(APP_PATH)

        post_mock = mock('request')
        post_mock.expects(:basic_auth).with(API_KEY, '')
        post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data')

        json_response = 'gobbledygook'
        response_mock = mock('response')
        response_mock.expects(:body).returns(json_response)

        uri = URI('https://cloud.bitbar.com/api/me/files')
        Net::HTTP::Post.expects(:new)&.with(uri)&.returns post_mock
        Net::HTTP.expects(:start)&.with('cloud.bitbar.com',
                                        443,
                                        use_ssl: true)&.returns(response_mock)

        $logger.expects(:error).with("Expected JSON response, received: #{response_mock}").once
        $logger.expects(:error).with("App upload to BitBar failed after 1 attempts").once
        assert_raise(JSON::ParserError) do
          Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_PATH, nil, 1
        end
      end

      def test_upload_app_fail_then_retry
        $logger.expects(:info).with("Uploading app: #{APP_PATH}").times(2)

        File.expects(:new)&.with(APP_PATH, 'rb')&.returns('file').times(2)
        Maze::Helper.expects(:expand_path).with(APP_PATH).returns(APP_PATH).once

        post_mock = mock('request')
        post_mock.expects(:basic_auth).with(API_KEY, '').times(2)
        post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data').times(2)

        failed_json_response = 'gobbledygook'
        failed_response_mock = mock('failed_response')
        failed_response_mock.expects(:body).returns(failed_json_response).once

        success_json_response = JSON.dump(id: APP_ID)
        success_response_mock = mock('response')
        success_response_mock.expects(:body).returns(success_json_response).once

        uri = URI('https://cloud.bitbar.com/api/me/files')
        Net::HTTP::Post.expects(:new)&.with(uri)&.returns(post_mock).times(2)
        Net::HTTP.expects(:start)&.with('cloud.bitbar.com',
                                        443,
                                        use_ssl: true)&.times(2).returns(failed_response_mock).then.returns(success_response_mock)

        $logger.expects(:error).with("Expected JSON response, received: #{failed_response_mock}").once
        $logger.expects(:info).with("Uploaded app ID: #{APP_ID}").once
        $logger.expects(:info).with('You can use this ID to avoid uploading the same app more than once.').once

        id = Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_PATH
        assert_equal(APP_ID, id)
      end

      def test_upload_app_fail_with_retries
        $logger.expects(:info).with("Uploading app: #{APP_PATH}").times(5)

        File.expects(:new)&.with(APP_PATH, 'rb')&.returns('file').times(5)
        Maze::Helper.expects(:expand_path).with(APP_PATH).returns(APP_PATH).once

        post_mock = mock('request')
        post_mock.expects(:basic_auth).with(API_KEY, '').times(5)
        post_mock.expects(:set_form).with({ 'file' => 'file' }, 'multipart/form-data').times(5)

        json_response = 'gobbledygook'
        response_mock = mock('response')
        response_mock.expects(:body).returns(json_response).times(5)

        uri = URI('https://cloud.bitbar.com/api/me/files')
        Net::HTTP::Post.expects(:new)&.with(uri)&.returns(post_mock).times(5)
        Net::HTTP.expects(:start)&.with('cloud.bitbar.com',
                                        443,
                                        use_ssl: true)&.returns(response_mock).times(5)

        $logger.expects(:error).with("Expected JSON response, received: #{response_mock}").times(5)
        $logger.expects(:error).with("App upload to BitBar failed after 5 attempts").once
        assert_raise(JSON::ParserError) do
          Maze::Client::BitBarClientUtils.upload_app API_KEY, APP_PATH
        end
      end

      def test_dashboard_capabilities_no_git
        Maze::Runner.expects(:run_command).with(GIT_COMMAND).returns([[], 1])
        $logger.expects(:warn).with('Unable to determine project name, consider running Maze Runner from within a Git repository')
        $logger.expects(:info).with("BitBar project name: #{UNKNOWN_PROJECT}")
        $logger.expects(:info).with("BitBar test run: #{UUID}")

        hash = BitBarClientUtils.dashboard_capabilities

        expected_hash = {
          'bitbar:options' => {
            bitbar_project: UNKNOWN_PROJECT,
            bitbar_testrun: UUID
          }
        }
        assert_equal expected_hash, hash
      end

      def test_dashboard_capabilities_buildkite
        $logger.expects(:info).with('Using BUILDKITE_PIPELINE_SLUG for BitBar project name')
        $logger.expects(:info).with('BitBar project name: slug')
        $logger.expects(:info).with('BitBar test run: 1234 - Android 6 tests (3)')

        ENV['BUILDKITE'] = 'true'
        ENV['BUILDKITE_PIPELINE_SLUG'] = 'slug'
        ENV['BUILDKITE_BUILD_NUMBER'] = '1234'
        ENV['BUILDKITE_LABEL'] = 'Android 6 tests'
        ENV['BUILDKITE_RETRY_COUNT'] = "3"

        hash = BitBarClientUtils.dashboard_capabilities

        expected_hash = {
          'bitbar:options' => {
            bitbar_project: 'slug',
            bitbar_testrun: '1234 - Android 6 tests (3)'
          }
        }
        assert_equal expected_hash, hash
      end

      def test_dashboard_capabilities_local_git
        Maze::Runner.expects(:run_command).with(GIT_COMMAND).returns([[REPO_PATH], 0])
        $logger.expects(:info).with("BitBar project name: #{REPO_NAME}")
        $logger.expects(:info).with("BitBar test run: #{UUID}")

        hash = BitBarClientUtils.dashboard_capabilities
        expected_hash = {
          'bitbar:options' => {
            bitbar_project: REPO_NAME,
            bitbar_testrun: UUID
          }
        }
        assert_equal expected_hash, hash
      end
    end
  end
end
