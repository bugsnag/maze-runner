class SpanSupport
  class << self


    spans = spans_from_request_list(Maze::Server.list_for('traces'))
    found_spans = spans.find_all { |span| span['name'].eql?(span_name) }
    raise Test::Unit::AssertionFailedError.new "No spans were found with the name #{span_name}" if found_spans.empty?


  end
end
