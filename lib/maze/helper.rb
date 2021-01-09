# frozen_string_literal: true

require 'digest/sha1'
require 'json'

# A collection of helper routines
module Maze
  class << self
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

    def valid_bugsnag_integrity_header(request)
      header = request[:request]['Bugsnag-Integrity']
      return false if header.nil?

      digests = request[:digests]
      if header.start_with?('sha1')
        computed_digest = "sha1 #{digests[:sha1]}"
      elsif header.start_with?('simple')
        computed_digest = "simple #{digests[:simple]}"
      else
        return false
      end
      header == computed_digest
    end
  end
end
