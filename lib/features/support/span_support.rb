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
  end
end
