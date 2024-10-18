require 'bugsnag/api'

module Maze
  module Client
    module Bugsnag
      # An abstraction for the underlying Bugsnag data access
      class DataAccessApi
        # @param api_key The Bugsnag API key
        # @param endpoint The endpoint to use for the Bugsnag Data Access API
        # @param project_id The project ID to use for the Bugsnag Data Access API
        def initialize
          @auth_token = Maze.config.bugsnag_data_access_api_key
          @endpoint = Maze.config.bugsnag_data_access_api_endpoint
          @project_id = Maze.config.bugsnag_data_access_project_id
          @client = create_client(auth_token: @auth_token, endpoint: @endpoint, project_id: @project_id)
        end

        def set_project_id(project_id)
          @project_id = project_id
          @client = create_client(auth_token: @auth_token, endpoint: @endpoint, project_id: @project_id)
        end

        def get_event(event_id)
          @client.event(@project_id, event_id)
        end

        def create_project(org_id, name, type)
          @client.create_project(org_id, name, type)
        end

        def get_project_api_key(project_id)
          project = @client.project(project_id)
          project['api_key']
        end

        def get_first_org_id
          orgs = @client.organizations
          orgs.first['id']
        end

        private

        def create_client(auth_token:, endpoint:, project_id:, opts: {})
          opts[:auth_token] = auth_token
          opts[:endpoint] = endpoint
          opts[:project_id] = project_id
          if endpoint.start_with?('http')
            opts[:connection_options] = {
              ssl: {
                verify: false
              }
            }
          end
          ::Bugsnag::Api::Client.new(opts)
        end
      end
    end
  end
end
