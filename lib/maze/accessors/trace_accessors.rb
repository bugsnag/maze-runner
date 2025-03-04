# frozen_string_literal: true

module Maze
  module Accessors
    # Provides functions for accessing and testing traces and spans 
    class TraceAccessors
      class << self
        # Traces

        # Retrieves a value within a trace
        #
        # @param list [String] The name of the list to get spans from
        # @param field [String] The field to check the attributes of
        # @param attribute [String] The attribute to check
        #
        # @returns [String|Integer] A string or integer representation of the attribute
        def attribute_by_key(list, field, attribute)
          requests = Maze::Server.list_for(list)
          attributes = Maze::Helper.read_key_path(requests.current[:body], "#{field}.attributes")
          attributes&.find { |a| a['key'].eql?(attribute) }
        end

        # Checks that an attribute value has a given type and value
        # Doesn't make assertions
        #
        # @param attribute_value [Hash] The attribute to test
        # @param expected_type [String] The type expected
        # @param expected_value [String] The value expected
        #
        # @returns [Boolean] Whether the attribute matched the given values
        def attribute_value_matches?(attribute_value, expected_type, expected_value)
          # Check that the required value type key is present
          unless attribute_value.keys.include?(expected_type)
            return false
          end

          case expected_type
          when 'bytesValue', 'stringValue'
            expected_value.eql?(attribute_value[expected_type])
          when 'intValue'
            expected_value.to_i.eql?(attribute_value[expected_type].to_i)
          when 'doubleValue'
            expected_value.to_f.eql?(attribute_value[expected_type].to_f)
          when 'boolValue'
            expected_value = expected_value.downcase.eql?('true') if expected_value.is_a?(String)
            tested_value = attribute_value[expected_type]
            tested_value = tested_value.downcase.eql?('true') if tested_value.is_a?(String)
            expected_value.eql?(tested_value)
          when 'arrayValue'
            expected_value.eql?(attribute_value[expected_type]['values'])
          when 'kvlistValue'
            $logger.error('Span attribute validation does not currently support the "kvlistValue" type')
            false
          else
            $logger.error("An invalid attribute type was expected: '#{expected_type}'")
            false
          end
        end

        # Spans

        # Checks that an amount of spans have been received, returning the count
        # Also validates requests against the trace schema
        #
        # @param list [String] The name of the list to check
        # @param minimum [Integer] The minimum required amount of spans to stop waiting for
        def received_span_count(list, minimum)
          timeout = Maze.config.receive_requests_wait
          wait = Maze::Wait.new(timeout: timeout)

          wait.until { spans_from_request_list(list).size >= minimum }
          received_count = spans_from_request_list(list).size

          Maze::Schemas::Validator.validate_payload_elements(Maze::Server.list_for(list), 'trace')

          received_count
        end

        # Retreives and returns all spans from a given request list
        #
        # @param list [String] The name of the list to get spans from
        # 
        # @returns [Array] A list of spans found within the given list
        def spans_from_request_list(list)
          request_list = Maze::Server.list_for(list)
          return request_list.remaining
                             .flat_map { |req| req[:body]['resourceSpans'] }
                             .flat_map { |r| r['scopeSpans'] }
                             .flat_map { |s| s['spans'] }
                             .select { |s| !s.nil? }
        end

        # Searches for all spans with a given name
        #
        # @param list [String] The request list to check
        # @param name [String] The name to search for
        #
        # @returns [Array] An array of found results
        def span_by_name(list, name)
          spans = spans_from_request_list(list)
          spans.find_all { |span| span['name'].eql?(name) }
        end
      end
    end
  end
end
