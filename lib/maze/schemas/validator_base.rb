# frozen_string_literal: true

module Maze
  module Schemas
    class ValidatorBase

      HEX_STRING_16 = '^[A-Fa-f0-9]{16}$'
      HEX_STRING_32 = '^[A-Fa-f0-9]{32}$'
      HOUR_TOLERANCE = 60 * 60 * 1000 * 1000 * 1000 # 1 hour in nanoseconds

      # Whether the payloads passed the validation, one of true, false, or nil (not run)
      #   @returns [Boolean|nil] Whether the validation was successful
      attr_reader :success

      # An array of error messages if the validation failed
      #  @returns [Array] The error messages
      attr_reader :errors

      # Creates the validator
      #
      #   @param request [Hash] The trace request to validate
      def initialize(request)
        @headers = request[:request].header
        @body = request[:body]
        @success = nil
        @errors = []
      end

      def validate
        # By default the validation will pass
        @success = true
      end

      def regex_comparison(path, regex)
        element_value = Maze::Helper.read_key_path(@body, path)
        expected = Regexp.new(regex)
        unless expected.match(element_value)
          @success = false
          @errors << "Element '#{path}' was expected to match the regex '#{regex}', but was '#{element_value}'"
        end
      end

      def element_int_in_range(path, range)
        element_value = Maze::Helper.read_key_path(@body, path)
        if element_value.nil? || !element_value.kind_of?(Integer)
          @success = false
          @errors << "Element '#{path}' was expected to be an integer, was '#{element_value}'"
          return
        end
        unless range.include?(element_value)
          @success = false
          @errors << "Element '#{path}':'#{element_value}' was expected to be in the range '#{range}'"
        end
      end

      def element_contains(path, key_value, value_type=nil, possible_values=nil)
        container = Maze::Helper.read_key_path(@body, path)
        if container.nil? || !container.kind_of?(Array)
          @success = false
          @errors << "Element '#{path}' was expected to be an array, was '#{container}'"
          return
        end
        element = container.find { |value| value['key'].eql?(key_value) }
        unless element
          @success = false
          @errors << "Element '#{path}' did not contain a value with the key '#{key_value}'"
          return
        end
        if value_type && possible_values
          unless element['value'] && element['value'][value_type] && possible_values.include?(element['value'][value_type])
            @success = false
            @errors << "Element '#{path}':'#{element}' did not contain a value of '#{value_type}' from '#{possible_values}'"
          end
        end
      end

      def each_element_contains(container_path, attribute_path, key_value)
        container = Maze::Helper.read_key_path(@body, container_path)
        if container.nil? || !container.kind_of?(Array)
          @success = false
          @errors << "Element '#{container_path}' was expected to be an array, was '#{container}'"
          return
        end
        container.each_with_index do |_item, index|
          element_contains("#{container_path}.#{index}.#{attribute_path}", key_value)
        end
      end

      def element_a_greater_or_equal_element_b(path_a, path_b)
        element_a = Maze::Helper.read_key_path(@body, path_a)
        element_b = Maze::Helper.read_key_path(@body, path_b)
        unless element_a && element_b && element_a >= element_b
          @success = false
          @errors << "Element '#{path_a}':'#{element_a}' was expected to be greater than or equal to '#{path_b}':'#{element_b}'"
        end
      end

      def validate_timestamp(path, tolerance)
        return unless Maze.config.span_timestamp_validation
        timestamp = Maze::Helper.read_key_path(@body, path)
        unless timestamp.kind_of?(String)
          @success = false
          @errors << "Timestamp was expected to be a string, was '#{timestamp.class.name}'"
          return
        end
        parsed_timestamp = timestamp.to_i
        unless parsed_timestamp > 0
          @success = false
          @errors << "Timestamp was expected to be a positive integer, was '#{parsed_timestamp}'"
          return
        end
        time_in_nanos = Time.now.to_i * 1000000000
        unless (time_in_nanos - parsed_timestamp).abs < tolerance
          @success = false
          @errors << "Timestamp was expected to be within #{tolerance} nanoseconds of the current time (#{time_in_nanos}), was '#{parsed_timestamp}'"
        end
      end

      def validate_header(name)
        value = @headers[name]
        if value.nil? || value.size > 1
          @errors << "Expected exactly one value for header #{name}, received #{value || 'nil'}"
        else
          yield value[0]
        end
      end
    end
  end
end
