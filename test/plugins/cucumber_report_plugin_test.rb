# frozen_string_literal: true

require 'test_helper'
require_relative '../../lib/maze/plugins/cucumber_report_plugin'

class CucumberReportPluginTest < Test::Unit::TestCase

  DRIVER_MOCK_CLASS = 'driver_mock_class'
  CONFIG_MOCK_CLASS = 'config_mock_class'
  CUC_CONFIG_MOCK_CLASS = 'cuc_config_mock_class'
  FARM_MOCK = 'farm_mock'
  DEVICE_MOCK = 'device_mock'
  OS_MOCK = 'os_mock'
  OS_VERSION_MOCK = 'os_version_mock'
  TMS_URI_MOCK = 'tms_uri_mock'
  TMS_TOKEN_MOCK = 'tms_token_mock'
  BUILDKITE_PIPELINE_NAME = 'BUILDKITE_PIPELINE_NAME'
  BUILDKITE_REPO = 'BUILDKITE_REPO'
  BUILDKITE_BUILD_URL = 'BUILDKITE_BUILD_URL'
  BUILDKITE_BRANCH = 'BUILDKITE_BRANCH'
  BUILDKITE_MESSAGE = 'BUILDKITE_MESSAGE'
  BUILDKITE_LABEL = 'BUILDKITE_LABEL'
  BUILDKITE_COMMIT = 'BUILDKITE_COMMIT'

  def setup
    # Allow driver to be configured
    $driver_mock = mock(DRIVER_MOCK_CLASS)
    $driver_mock.stubs(:class).returns(DRIVER_MOCK_CLASS)
    Maze.stubs(:driver).returns($driver_mock)

    # Allow config to be configured
    $config_mock = mock(CONFIG_MOCK_CLASS)
    $config_mock.stubs(:farm).returns(FARM_MOCK)
    $config_mock.stubs(:device).returns(DEVICE_MOCK)
    $config_mock.stubs(:os).returns(OS_MOCK)
    $config_mock.stubs(:os_version).returns(OS_VERSION_MOCK)
    Maze.stubs(:config).returns($config_mock)

    # Cucumber config mock
    $cuc_config_mock = mock(CUC_CONFIG_MOCK_CLASS)

    # Setup environment variables used for data
    ENV['BUILDKITE'] = 'true'
    ENV['BUILDKITE_PIPELINE_NAME'] = BUILDKITE_PIPELINE_NAME
    ENV['BUILDKITE_REPO'] = BUILDKITE_REPO
    ENV['BUILDKITE_BUILD_URL'] = BUILDKITE_BUILD_URL
    ENV['BUILDKITE_BRANCH'] = BUILDKITE_BRANCH
    ENV['BUILDKITE_MESSAGE'] = BUILDKITE_MESSAGE
    ENV['BUILDKITE_LABEL'] = BUILDKITE_LABEL
    ENV['BUILDKITE_COMMIT'] = BUILDKITE_COMMIT
  end

  def start_logger_mock
    logger_mock = mock('logger')
    $logger = logger_mock
    logger_mock
  end

  def test_captured_data
    plugin = Maze::Plugins::CucumberReportPlugin.new
    assert_equal(DRIVER_MOCK_CLASS, plugin.report['configuration'][:driver_class])
    assert_equal(FARM_MOCK, plugin.report['configuration'][:device_farm])
    assert_equal(DEVICE_MOCK, plugin.report['configuration'][:device])
    assert_equal(OS_MOCK, plugin.report['configuration'][:os])
    assert_equal(OS_VERSION_MOCK, plugin.report['configuration'][:os_version])

    assert_equal(BUILDKITE_PIPELINE_NAME, plugin.report['build'][:pipeline])
    assert_equal(BUILDKITE_REPO, plugin.report['build'][:repo])
    assert_equal(BUILDKITE_BUILD_URL, plugin.report['build'][:build_url])
    assert_equal(BUILDKITE_BRANCH, plugin.report['build'][:branch])
    assert_equal(BUILDKITE_MESSAGE, plugin.report['build'][:message])
    assert_equal(BUILDKITE_LABEL, plugin.report['build'][:step])
    assert_equal(BUILDKITE_COMMIT, plugin.report['build'][:commit])
  end

  def test_install_plugin_no_uri
    logger = start_logger_mock
    logger.expects(:info).with('No test report will be delivered for this run')

    $config_mock.expects(:tms_uri).returns(false)
    # Stub to allow for it but don't expect the second call
    $config_mock.stubs(:tms_token).returns(true)

    plugin = Maze::Plugins::CucumberReportPlugin.new
    plugin.install_plugin($cuc_config_mock)
  end

  def test_install_plugin_no_token
    logger = start_logger_mock
    logger.expects(:info).with('No test report will be delivered for this run')

    $config_mock.expects(:tms_uri).returns(true)
    $config_mock.expects(:tms_token).returns(false)

    plugin = Maze::Plugins::CucumberReportPlugin.new
    plugin.install_plugin($cuc_config_mock)
  end

  def test_install_plugin_no_buildkite_env
    logger = start_logger_mock
    logger.expects(:info).with('No test report will be delivered for this run')

    ENV.delete('BUILDKITE')
    $config_mock.expects(:tms_uri).returns(true)
    $config_mock.expects(:tms_token).returns(true)

    plugin = Maze::Plugins::CucumberReportPlugin.new
    plugin.install_plugin($cuc_config_mock)
  end

  def test_install_plugin_success
    logger = start_logger_mock

    $config_mock.expects(:tms_uri).returns(true)
    $config_mock.expects(:tms_token).returns(true)

    formats_array = []
    $cuc_config_mock.expects(:formats).returns(formats_array)

    Maze::Plugins::CucumberReportPlugin.any_instance.expects(:at_exit).with_block_given

    plugin = Maze::Plugins::CucumberReportPlugin.new
    plugin.install_plugin($cuc_config_mock)

    assert_equal('json', formats_array.first[0])
    assert_equal({}, formats_array.first[1])
    assert_equal(plugin.json_report_stream, formats_array.first[2])
    assert_equal(StringIO, formats_array.first[2].class)
  end

  def test_send_report_success
    logger = start_logger_mock
    plugin = Maze::Plugins::CucumberReportPlugin.new

    $config_mock.expects(:tms_uri).returns(TMS_URI_MOCK)
    $config_mock.expects(:tms_token).returns(TMS_TOKEN_MOCK)

    report_mock = {
      foo: 'bar'
    }
    Maze::Plugins::CucumberReportPlugin.any_instance.expects(:report).returns(report_mock)

    mock_uri = URI("#{TMS_URI_MOCK}/report")

    request_mock = {}
    request_mock.expects(:body=).with(JSON.generate(report_mock))
    Net::HTTP::Post.expects(:new).with() { |uri|
      uri.to_s.eql?(mock_uri.to_s)
    }.returns(request_mock)

    http_mock = mock('http_mock')
    http_mock.expects(:request).with(request_mock)
    Net::HTTP.expects(:new).with(mock_uri.hostname, mock_uri.port).returns(http_mock)

    $logger.expects(:info).with('Cucumber report delivered to test report server')

    plugin.send(:send_report)

    assert_equal('application/json', request_mock['Content-Type'])
    assert_equal(TMS_TOKEN_MOCK, request_mock['Authorization'])
  end

  def test_send_report_error
    logger = start_logger_mock
    plugin = Maze::Plugins::CucumberReportPlugin.new

    $config_mock.expects(:tms_uri).returns(TMS_URI_MOCK)
    $config_mock.expects(:tms_token).returns(TMS_TOKEN_MOCK)

    report_mock = {
      foo: 'bar'
    }
    Maze::Plugins::CucumberReportPlugin.any_instance.expects(:report).returns(report_mock)

    mock_uri = URI("#{TMS_URI_MOCK}/report")

    request_mock = {}
    request_mock.expects(:body=).with(JSON.generate(report_mock))
    Net::HTTP::Post.expects(:new).with() { |uri|
      uri.to_s.eql?(mock_uri.to_s)
    }.returns(request_mock)

    http_mock = mock('http_mock')
    http_mock.expects(:request).with(request_mock).raises(RuntimeError, 'TEST_ERROR')
    Net::HTTP.expects(:new).with(mock_uri.hostname, mock_uri.port).returns(http_mock)

    $logger.expects(:warn).with('Report delivery attempt failed')
    $logger.expects(:warn).with('TEST_ERROR')

    plugin.send(:send_report)

    assert_equal('application/json', request_mock['Content-Type'])
    assert_equal(TMS_TOKEN_MOCK, request_mock['Authorization'])
  end
end

