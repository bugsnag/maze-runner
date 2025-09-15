class ErrorConfigSupport
  class << self
    def prepare_error_config(table_hashes)

      error_config = {
        headers: {},
      }
      table_hashes.each do |hash|
        type = hash['type']
        name = hash['name']
        value = hash['value']

        case type
        when 'header'
          error_config[:headers][name] = value
        when 'property'
          case name
          when 'status'
            error_config[:status] = value.to_i
          when 'body'
            if value.start_with?('@')
              body = File.read(value[1..])
            else
              body = value
            end
            error_config[:body] = body
            error_config[:headers]['ETag'] = Digest::SHA1.hexdigest(body.to_s)
          else
            raise "Unknown property '#{name}'"
          end
        else
          raise "Unknown type '#{type}'"
        end
      end

      Maze::Server.error_configs.add(error_config)
    end
  end
end
