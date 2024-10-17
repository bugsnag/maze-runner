module Maze
  module Client
    module Bugsnag
      # An abstraction for the underlying Bugsnag data access
      class DataAccessApi
        # @param api_key The Bugsnag API key
        # @param endpoint The endpoint to use for the Bugsnag Data Access API#
        # @param project_id The project ID to use for the Bugsnag Data Access API
        def initialize
          @api_key = Maze.config.bugsnag_data_access_api_key
          @endpoint = Maze.config.bugsnag_data_access_api_endpoint
          @project_id = Maze.config.bugsnag_data_access_project_id
          opts = {
            api_key: @api_key,
            endpoint: @endpoint,
            project_id: @project_id
          }
          if @endpoint.start_with?('http')
            opts.connection_options = { ssl: { verify: false } }
          end
          @client = Bugsnag::Api::Client.new(opts)
        end

        def get_event(event_id)
          @client.event(@project_id, event_id)
        end
      end
    end
  end
end
