module Maze
  # Utils supporting the BitBar device farm integration
  module Client
    class BitBarApiClient
      BASE_BITBAR_API_URI = 'https://cloud.bitbar.com/api/v2/me'

      # Get the id of a device group given its name
      def get_device_group_id(device_group_name)
        query = {
          'filter': "displayName_eq_#{device_group_name}"
        }
        device_groups = query_api('device-groups', query)
        if device_groups['data'].size != 1
          $logger.error "Expected exactly one group with name #{device_group_name}, found #{devices['data'].size}"
          raise "Failed to find a device group named '#{device_group_name}'"
        end
        device_groups['data'][0]['id']
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
      def query_api(path, query=nil)
        if query
          encoded_query = URI.encode_www_form(query)
          uri = URI("#{BASE_BITBAR_API_URI}/#{path}?#{encoded_query}")
        else
          uri = URI("#{BASE_BITBAR_API_URI}/#{path}")
        end
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(Maze.config.access_key, '')
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        JSON.parse(res.body)
      end
    end
  end
end

