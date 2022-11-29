# frozen_string_literal: true

module Maze
  module Servlets
    class TraceServlet < Servlet
      def set_response_header(header)
        super
        value = Maze::Server.sampling_probability
        header['Bugsnag-Sampling-Probability'] =  value unless value == 'null'
      end
    end
  end
end
