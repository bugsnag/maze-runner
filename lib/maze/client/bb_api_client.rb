module Maze
  # Utils supporting the BitBar device farm integration
  module Client
    class BitBarApiClient
      BASE_URI = 'https://cloud.bitbar.com/api'
      USER_SPECIFIC_URI = "#{BASE_URI}/v2/me"

      def initialize(access_key)
        @access_key = access_key
      end

      # Get a list of all available device groups
      def get_device_group_list
        query_api('device-groups')
      end

      # Get a list of all available devices in a device group
      def get_device_list_for_group(device_group_id)
        path = "device-groups/#{device_group_id}/devices"
        query_api(path)
      end

      # Get the id(s) of a one or more device groups given their names.  Multiple device group names should be separated
      # by a pipe (which is directly supported by the BitBar API)
      def get_device_group_ids(device_group_names)
        query = {
          'filter': "displayName_in_#{device_group_names}"
        }
        device_groups = query_api('device-groups', query)
        if device_groups['data'].nil? || device_groups['data'].size == 0
          nil
        else
          device_groups['data'].map { |group| group['id'] }
        end
      end

      def find_device_in_groups(device_group_ids)
        all_devices = []
        device_group_ids.each do |group_id|
          path = "device-groups/#{group_id}/devices"
          query = {
            'filter': "online_eq_true"
          }
          all_devices += query_api(path, query)['data']
        end

        $logger.trace "All available devices in group(s) #{device_group_ids}: #{JSON.pretty_generate(all_devices)}"
        filtered_devices = all_devices.reject { |device| device['locked'] }

        # Only send gauges to DataDog for single device groups
        if device_group_ids.size == 1
          Maze::Plugins::DatadogMetricsPlugin.send_gauge('bitbar.device.available', all_devices.size, [Maze.config.device])
          Maze::Plugins::DatadogMetricsPlugin.send_gauge('bitbar.device.unlocked', filtered_devices.size, [Maze.config.device])
        end
        return filtered_devices.size, filtered_devices.sample
      end

      def find_device(device_name)
        path = "devices"
        query = {
          'filter': "displayName_eq_#{device_name};online_eq_true",
        }
        all_devices = query_api(path, query, BASE_URI)['data']
        if all_devices.size == 0
          Maze::Helper.error_exit "No devices found with name '#{device_name}'"
        else
          $logger.trace "All available devices with name #{device_name}: #{JSON.pretty_generate(all_devices)}"
          filtered_devices = all_devices.reject { |device| device['locked'] }
          if filtered_devices.size == 0
            Maze::Helper.error_exit "None of the #{all_devices.size} devices with name '#{device_name}' are currently available"
          else
            $logger.info "#{filtered_devices.size} of #{all_devices.size} devices with name '#{device_name}' are available"
          end

          return filtered_devices.sample
        end
      end

      def get_device_session_info(session_id)
        query = {
          'filter': "clientSideId_eq_#{session_id}"
        }
        data = query_api('device-sessions', query)['data']
        if data.size == 1
          {
            :dashboard_link => data[0]['uiLink'],
            :device_name => data[0]['device']['displayName']
          }
        else
          $logger.warn "Could not retrieve details for device session #{session_id}, BitBar may not have had time to create it yet."
          nil
        end
      end

      def get_projects(pattern)
        query = {
          'limit': "1000"
        }

        project_data = query_api('projects', query)

        begin
          projects = Hash.new
          project_data['data'].each do |child|
            if child['name'].match(pattern)
              projects[child['name']] = child['id']
            end
          end
        rescue StandardError => e
          $logger.error "Error getting projects from BitBar: #{e}"
          raise
        end
        projects
      end

      def delete_project (id)
        response = query_api "projects/#{id}", nil, USER_SPECIFIC_URI, "delete"
      end

      private

      # Queries the BitBar REST API
      def query_api(path, query=nil, uri=USER_SPECIFIC_URI, method="get")
        if query
          encoded_query = URI.encode_www_form(query)
          uri = URI("#{uri}/#{path}?#{encoded_query}")
        else
          uri = URI("#{uri}/#{path}")
        end

        if method == "get"
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(@access_key, '')
          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          return JSON.parse(res.body)
        elsif method == "delete"
          request = Net::HTTP::Delete.new(uri)
          request.basic_auth(@access_key, '')
          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(request)
          end

          return res
        end
      end
    end
  end
end

