# frozen_string_literal: true

module Maze
  module Servlets
    class TraceServlet < Servlet
      def set_response_header(header)
        super

        value = Maze::Server.sampling_probability
        header['Bugsnag-Sampling-Probability'] = value unless value == 'null'

        header['Access-Control-Expose-Headers'] = 'Bugsnag-Sampling-Probability'
      end

      private

      def add_request(request)
        if sampling_request? request
          Server.sampling_requests.add request
        else
          Server.traces.add request
        end
      end

      def sampling_request?(request)
        body = request[:body]
        body.keys.eql?(['resourceSpans']) && body['resourceSpans'].empty?
      end
    end
  end
end
