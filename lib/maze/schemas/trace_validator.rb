# frozen_string_literal: true

require_relative '../helper'

module Maze
  module Schemas

    # Contains a set of pre-defined validations for ensuring traces are correct
    class TraceValidator

      # Whether the trace passed the validation, one of true, false, or nil (not run)
      #   @returns [Boolean|nil] Whether the validation was successful
      attr_reader :success
      attr_reader :errors

      # Creates the validator
      #
      #   @param body [Hash] The body of the trace to validate
      def initialize(body)
        @body = body
        @success = nil
        @errors = []
      end

      # Runs the validation against the trace given
      def validate
        @success = true

        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.spanId', '^[A-Fa-f0-9]{16}$')
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.traceId', '^[A-Fa-f0-9]{32}$')
        element_int_in_range('resourceSpans.0.scopeSpans.0.spans.0.kind', 0..5)
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.startTimeUnixNano', '^[0-9]+$')
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.endTimeUnixNano', '^[0-9]+$')
        element_contains('resourceSpans.0.resource.attributes', 'deployment.environment')
        element_contains('resourceSpans.0.resource.attributes', 'telemetry.sdk.name')
        element_contains('resourceSpans.0.resource.attributes', 'telemetry.sdk.version')
        element_a_greater_or_equal_element_b(
          'resourceSpans.0.scopeSpans.0.spans.0.endTimeUnixNano',
          'resourceSpans.0.scopeSpans.0.spans.0.startTimeUnixNano'
        )
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

      def element_a_greater_or_equal_element_b(path_a, path_b)
        element_a = Maze::Helper.read_key_path(@body, path_a)
        element_b = Maze::Helper.read_key_path(@body, path_b)
        unless element_a && element_b && element_a >= element_b
          @success = false
          @errors << "Element '#{path_a}':'#{element_a}' was expected to be greater than or equal to '#{path_b}':'#{element_b}'"
        end
      end
    end
  end
end
