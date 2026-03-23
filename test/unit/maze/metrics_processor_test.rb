# frozen_string_literal: true

require 'ostruct'
require 'set'
require_relative '../test_helper'
require_relative '../../../lib/maze/metrics_processor'

# noinspection RubyNilAnalysis
class MetricsProcessorTest < Test::Unit::TestCase

  FILE_PATH = 'path/metrics.csv'

  def setup
    Maze.scenario = OpenStruct.new(name: 'scenario_name', location: 'scenario_location')
  end

  def test_uniform_metrics
    metrics = Maze::RequestList.new

    metric1 = {"name" => "edie", "age" => 7}
    metric2 = {"name" => "henry", "age" => 10}
    metric3 = {"name" => "steve", "age" => 43}

    metrics.add({:body => metric1})
    metrics.add({:body => metric2})
    metrics.add({:body => metric3})

    processor = Maze::MetricsProcessor.new(metrics)

    file_mock = mock('file')
    File.stubs(:open).yields(file_mock)

    # File.expects(:open).with().yields(file_mock)
    file_mock.expects(:puts).with('age,name')
    file_mock.expects(:puts).with('7,edie')
    file_mock.expects(:puts).with('10,henry')
    file_mock.expects(:puts).with('43,steve')

    processor.process
  end

  def test_mixed_metrics
    metrics = Maze::RequestList.new

    metric1 = {"name" => "bob", "height" => "120,0"}
    metric2 = {"name" => "chris penny", "shoeSize" => 10}
    metric3 = {"name" => "clare", "age" => "40"}

    metrics.add({:body => metric1})
    metrics.add({:body => metric2})
    metrics.add({:body => metric3})

    processor = Maze::MetricsProcessor.new(metrics)

    file_mock = mock('file')
    File.stubs(:open).yields(file_mock)

    # File.expects(:open).with().yields(file_mock)
    file_mock.expects(:puts).with('age,height,name,shoeSize')
    file_mock.expects(:puts).with(',"120,0",bob,')
    file_mock.expects(:puts).with(',,"chris penny",10')
    file_mock.expects(:puts).with('40,,clare,')

    processor.process
  end
end
