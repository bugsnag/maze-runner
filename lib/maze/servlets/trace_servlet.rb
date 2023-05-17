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
        if p_value_request? request
          Server.p_values.add request
        else
          Server.traces.add request
        end
      end

      def p_value_request?(request)
        body = request[:body]
        body.keys.eql?(['resourceSpans']) && body['resourceSpans'].empty?
      end
    end
  end
end
