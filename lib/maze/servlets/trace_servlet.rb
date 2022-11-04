# frozen_string_literal: true

module Maze
  module Servlets
    class TraceServlet < Servlet
      def set_response_header(header)
        super

        header['Bugsnag-Sampling-Probability'] = '1'
      end
    end
  end
end
