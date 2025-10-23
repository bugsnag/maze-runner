# frozen_string_literal: true
require 'json'
require 'ostruct'
require_relative '../../../../lib/maze/server'
require_relative '../../../../lib/features/support/span_support'
require_relative '../../test_helper'

class SpanSupportTest < Test::Unit::TestCase

  def setup
    Maze.scenario = OpenStruct.new(name: 'scenario_name', location: 'scenario_location')
  end

  def test_spans_from_request_list
    trace = load_hash_from_json_file('test/unit/features/support/span_support_test_data/instrumentation_spans.json')
    add_trace_to_request_list(trace)
    spans = SpanSupport.spans_from_request_list(Maze::Server.traces)

    assert_equal(10, spans.size)
    assert_equal('[AppStartPhase/Framework]', spans[0]['name'])
    assert_equal('[ViewLoadPhase/ActivityCreate]SplashScreenActivity', spans[1]['name'])
    assert_equal('[ViewLoadPhase/ActivityStart]SplashScreenActivity', spans[2]['name'])
    assert_equal('[ViewLoadPhase/ActivityResume]SplashScreenActivity', spans[3]['name'])
    assert_equal('[ViewLoadPhase/ActivityCreate]MainActivity', spans[4]['name'])
    assert_equal('[ViewLoadPhase/ActivityStart]MainActivity', spans[5]['name'])
    assert_equal('[ViewLoadPhase/ActivityResume]MainActivity', spans[6]['name'])
    assert_equal('[ViewLoad/Activity]SplashScreenActivity', spans[7]['name'])
    assert_equal('[AppStart/AndroidCold]SplashScreen', spans[8]['name'])
    assert_equal('[ViewLoad/Activity]MainActivity', spans[9]['name'])
  end
end
