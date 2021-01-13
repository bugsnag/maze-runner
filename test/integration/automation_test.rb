require_relative '../test_helper'
require 'fileutils'

class SampleTest < Test::Unit::TestCase

  def test_running_a_docker_harness
    run_scenario('test/fixtures/docker-app')
  end

  def test_comparing_requests_to_json_files
    run_scenario('test/fixtures/comparison')
  end

  def test_interactive_cli
    run_scenario('test/fixtures/cli')
  end

  def test_http_response_codes
    run_scenario('test/fixtures/http-response')
  end

  def run_scenario fixture_path
    Dir.chdir(fixture_path) do
      Process.wait Process.spawn('bundle', 'exec', 'maze-runner')
      status = $?.exitstatus
      assert_equal(0, status, "Scenario failed: #{fixture_path}")
    end
  end
end
