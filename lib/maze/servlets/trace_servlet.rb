# frozen_string_literal: true

module Maze
  module Servlets
    class TraceServlet < Servlet
      def set_response_header(header)
        super

        header['Bugsnag-Sampling-Probability'] = Maze::Server.sampling_probability
      end
    end
  end
end
