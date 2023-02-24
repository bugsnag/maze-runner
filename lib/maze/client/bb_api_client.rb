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

      # Get the id of a device group given its name
      def get_device_group_id(device_group_name)
        query = {
          'filter': "displayName_eq_#{device_group_name}"
        }
        device_groups = query_api('device-groups', query)
        if device_groups['data'].nil? || device_groups['data'].size == 0
          nil
        else
          device_groups['data'][0]['id']
        end
      end

      def find_device_in_group(device_group_id)
        path = "device-groups/#{device_group_id}/devices"
        query = {
          'filter': "online_eq_true"
        }
        all_devices = query_api(path, query)

        $logger.debug "All available devices in group #{device_group_id}: #{JSON.pretty_generate(all_devices)}"
        filtered_devices = all_devices['data'].reject { |device| device['locked'] }
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
          $logger.debug "All available devices with name #{device_name}: #{JSON.pretty_generate(all_devices)}"
          filtered_devices = all_devices.reject { |device| device['locked'] }
          if filtered_devices.size == 0
            Maze::Helper.error_exit "None of the #{all_devices.size} devices with name '#{device_name}' are currently available"
          else
            $logger.info "#{filtered_devices.size} of #{all_devices.size} devices with name '#{device_name}' are available"
          end

          return filtered_devices.sample
        end
      end

      def get_device_session_ui_link(session_id)
        query = {
          'filter': "clientSideId_eq_#{session_id}"
        }
        data = query_api('device-sessions', query)['data']
        if data.size == 1
          data[0]['uiLink']
        else
          $logger.warn "Failed to get UI link for session #{session_id}.  Expected exactly 1 device-session, found #{data.size}"
        end
      end

      private

      # Queries the BitBar REST API
      def query_api(path, query=nil, uri=USER_SPECIFIC_URI)
        if query
          encoded_query = URI.encode_www_form(query)
          uri = URI("#{uri}/#{path}?#{encoded_query}")
        else
          uri = URI("#{uri}/#{path}")
        end
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(@access_key, '')
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        JSON.parse(res.body)
      end
    end
  end
end

