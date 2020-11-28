# frozen_string_literal: true

# Parses a request's query string, because WEBrick doesn't in POST requests
#
# @param request [Hash] The received request
#
# @return [Hash] The parsed query string.
def parse_querystring(request)
  CGI.parse(request[:request].query_string)
end

# Enables traversal of a hash using Mongo-style dot notation.
#
# @example hash["array"][0]["item"] becomes "hash.array.0.item"
#
# @param hash [Hash] The hash to traverse
# @param key_path [String] The dot notation path within the hash
#
# @return [Any] The value found by the key path
def read_key_path(hash, key_path)
  value = hash
  key_path.split('.').each do |key|
    if key =~ /^(\d+)$/
      key = key.to_i
      if value.length > key
        value = value[key]
      else
        return nil
      end
    else
      if value.key? key
        value = value[key]
      else
        return nil
      end
    end
  end
  value
end
