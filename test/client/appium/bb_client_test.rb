# frozen_string_literal: true

require 'test_helper'
require_relative '../../../lib/maze'
require_relative '../../../lib/maze/client/appium/base_client'
require_relative '../../../lib/maze/client/appium/bb_client'
require_relative '../../../lib/maze/runner'

class BitBarUtilsTest < Test::Unit::TestCase

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

    logger_mock = mock('logger')
    $logger = logger_mock

    Maze.run_uuid = UUID

    @client = Maze::Client::Appium::BitBarClient.new
  end

  def test_dashboard_capabilities_no_git
    Maze::Runner.expects(:run_command).with(GIT_COMMAND).returns([[], 1])
    $logger.expects(:warn).with('Unable to determine project name, consider running Maze Runner from within a Git repository')

    hash = @client.dashboard_capabilities

    expected_hash = {
      'bitbar:options' => {
        bitbar_project: UNKNOWN_PROJECT,
        bitbar_testrun: UUID
      }
    }
    assert_equal expected_hash, hash
  end

  def test_dashboard_capabilities_buildkite
    Maze::Runner.expects(:run_command).with(GIT_COMMAND).returns([[], 1])
    ENV['BUILDKITE'] = 'true'
    ENV['BUILDKITE_PIPELINE_SLUG'] = 'slug'
    ENV['BUILDKITE_BUILD_NUMBER'] = '1234'
    ENV['BUILDKITE_LABEL'] = 'Android 6 tests'

    hash = @client.dashboard_capabilities

    expected_hash = {
      'bitbar:options' => {
        bitbar_project: 'slug',
        bitbar_testrun: '1234 - Android 6 tests'
      }
    }
    assert_equal expected_hash, hash
  end

  def test_dashboard_capabilities_local_git
    Maze::Runner.expects(:run_command).with(GIT_COMMAND).returns([[REPO_PATH], 0])
    hash = @client.dashboard_capabilities
    expected_hash = {
      'bitbar:options' => {
        bitbar_project: REPO_NAME,
        bitbar_testrun: UUID
      }
    }
    assert_equal expected_hash, hash
  end
end