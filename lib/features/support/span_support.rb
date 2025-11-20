class SpanSupport
  class << self
    def spans_from_request_list(list)
      list.remaining
          .flat_map { |req| req[:body]['resourceSpans'] }
          .flat_map { |r| r['scopeSpans'] }
          .flat_map { |s| s['spans'] }
          .select { |s| !s.nil? }
    end

    def get_named_spans(span_name)
      spans = spans_from_request_list(Maze::Server.traces)
      named_spans = spans.find_all { |span| span['name'].eql?(span_name) }
      raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{span_name}" if named_spans.empty?
      named_spans
    end

    def named_span_exists?(span_name)
      spans = spans_from_request_list(Maze::Server.traces)
      named_spans = spans.find_all { |span| span['name'].eql?(span_name) }
      !named_spans.empty?
    end

    def assert_received_span_count(count)
      assert_received_spans(count, count)
    end

    def assert_received_minimum_span_count(minimum)
      assert_received_spans(minimum)
    end

    def assert_received_ranged_span_count(minimum, maximum)
      assert_received_spans(minimum, maximum)
    end

    def received_spans_names
      spans = spans_from_request_list(Maze::Server.traces)
      names spans.map { |span| span['name'] }

    end

    def assert_received_named_span(span_name)
      timeout = Maze.config.receive_requests_wait
      wait = Maze::Wait.new(timeout: timeout)
      received = wait.until { SpanSupport.named_span_exists?(span_name) }

      spans = Maze::Api::Model::SpanSet.new
      list = Maze::Server.traces
      list.remaining.each { |t| spans.add_from_trace_hash(t[:body]) }
      names = spans.size == 0 ? '.' : ", with names:\n#{spans.names.sort.join("\n")}"

      unless received
        raise Test::Unit::AssertionFailedError.new <<-MESSAGE
Expected span with name #{span_name} not received within the #{timeout}s timeout.  #{spans.size} spans were received#{names}
This could indicate that:
- Bugsnag crashed with a fatal error.
- Bugsnag did not make the requests that it should have done.
- The requests were made, but not deemed to be valid (e.g. missing integrity header).
- The requests made were prevented from being received due to a network or other infrastructure issue.
Please check the Maze Runner and device logs to confirm.)
        MESSAGE
      end

      Maze::Schemas::Validator.validate_payload_elements(list, 'trace')
    end

    def assert_received_spans(min_received, max_received = nil)
      timeout = Maze.config.receive_requests_wait
      wait = Maze::Wait.new(timeout: timeout)
      list = Maze::Server.traces
      received = wait.until { SpanSupport.spans_from_request_list(list).size >= min_received }
      received_count = SpanSupport.spans_from_request_list(list).size

      unless received
        raise Test::Unit::AssertionFailedError.new <<-MESSAGE
Expected #{min_received} spans but received #{received_count} within the #{timeout}s timeout.
This could indicate that:
- Bugsnag crashed with a fatal error.
- Bugsnag did not make the requests that it should have done.
- The requests were made, but not deemed to be valid (e.g. missing integrity header).
- The requests made were prevented from being received due to a network or other infrastructure issue.
Please check the Maze Runner and device logs to confirm.)
        MESSAGE
      end

      Maze.check.operator(max_received, :>=, received_count, "#{received_count} spans received") if max_received

      Maze::Schemas::Validator.validate_payload_elements(list, 'trace')
    end

    def store_named_span_field(span_name, field, store_key)
      spans = SpanSupport.get_named_spans(span_name)
      values = spans.map { |span| span[field] }.compact
      raise Test::Unit::AssertionFailedError.new "Expected 1 span named #{span_name}, found #{values.size}" unless values.size == 1

      value = Maze::Helper.read_key_path(spans[0], field)
      Maze::Store.values[store_key] = value.dup
    end
  end
end
