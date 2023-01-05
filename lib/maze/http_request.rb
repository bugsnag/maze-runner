require 'delegate'

module Maze
  class HttpRequest < SimpleDelegator
    def body
      @body ||= decode_body
    end

    private

    def decode_body
      delegate = __getobj__
      if %r{^gzip$}.match(delegate['Content-Encoding'])
        gz_element = Zlib::GzipReader.new(StringIO.new(delegate.body))
        gz_element.read
      else
        delegate.body
      end
    end
  end
end
