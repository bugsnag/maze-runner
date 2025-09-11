class ErrorConfigSupport
  class << self
    def prepare_error_config(hashes)

      error_config = { }
      hashes.each do |hash|
        type = hash['type']
        name = hash['name']
        value = hash['value']

        case type
        when 'header'
          error_config.headers[name] = value
        when 'property'
          case name
          when 'status'
            error_config[:status] = value.to_i
          when 'contents'
            error_config[:body] = value
          when 'contents_file'
            error_config.body = File.read(value)
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