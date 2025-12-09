require 'json'
require_relative '../../../test_helper'
require_relative '../../../../../lib/maze/api/model/span_set'

class SpanSetTest < Test::Unit::TestCase
  # Verifies that all fields and attributes are correctly parsed from a hash
  def test_span_from_hash
    # Load hash from file and create a populated span object
    test_file = File.read(File.join(__dir__, 'test_data', 'nested_spans_trace.json'))
    trace_hash = JSON.parse(test_file)
    span_set = Maze::Api::Model::SpanSet.from_trace_hash(trace_hash)

    # Check the span set contains the expected number of spans and names
    assert_equal(21, span_set.size)
    names = span_set.names.sort
    assert_equal('CustomRoot', names[0])
    assert_equal('DoStuff', names[1])
    assert_equal('LoadData', names[2])
    assert_equal('[AppStart/AndroidCold]SplashScreen', names[3])
    assert_equal('[AppStartPhase/Framework]', names[4])
    assert_equal('[ViewLoad/Activity]MainActivity', names[5])
    assert_equal('[ViewLoad/Activity]NestedSpansActivity', names[6])
    assert_equal('[ViewLoad/Activity]SplashScreenActivity', names[7])
    assert_equal('[ViewLoad/Fragment]FirstFragment', names[8])
    assert_equal('[ViewLoad/Fragment]SecondFragment', names[9])
    assert_equal('[ViewLoadPhase/ActivityCreate]MainActivity', names[10])
    assert_equal('[ViewLoadPhase/ActivityCreate]NestedSpansActivity', names[11])
    assert_equal('[ViewLoadPhase/ActivityCreate]SplashScreenActivity', names[12])
    assert_equal('[ViewLoadPhase/ActivityResume]MainActivity', names[13])
    assert_equal('[ViewLoadPhase/ActivityResume]NestedSpansActivity', names[14])
    assert_equal('[ViewLoadPhase/ActivityResume]SplashScreenActivity', names[15])
    assert_equal('[ViewLoadPhase/ActivityStart]MainActivity', names[16])
    assert_equal('[ViewLoadPhase/ActivityStart]NestedSpansActivity', names[17])
    assert_equal('[ViewLoadPhase/ActivityStart]SplashScreenActivity', names[18])
    assert_equal('[ViewLoadPhase/FragmentCreate]FirstFragment', names[19])
    assert_equal('[ViewLoadPhase/FragmentCreate]SecondFragment', names[20])
  end
end
