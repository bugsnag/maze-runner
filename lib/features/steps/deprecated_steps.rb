# @!group Deprecated steps

# Waits for a given number of spans to be received, which may be spread across one or more trace requests.
#
# @step_input span_count [Integer] The number of spans to wait for
When('I wait for {int} span(s)') do |span_count|
  assert_received_span_count(span_count, span_count)
end
