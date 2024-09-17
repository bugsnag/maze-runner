# frozen_string_literal: true

require_relative '../helper'
require_relative 'trace_schema'
require_relative 'validator_base'

module Maze
  module Schemas

    SAMPLING_HEADER_ENTRY = '((1(.0)?|0(\.[0-9]+)?):[0-9]+)'
    SAMPLING_HEADER = "^#{SAMPLING_HEADER_ENTRY}(;#{SAMPLING_HEADER_ENTRY})*$"

    # Contains a set of pre-defined validations for ensuring traces are correct
    class TraceValidator < ValidatorBase
      # Runs the validation against the trace given
      def validate
        # The tests are being run
        @success = true
        verify_against_schema
        validate_headers
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.spanId', HEX_STRING_16)
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.traceId', HEX_STRING_32)
        element_int_in_range('resourceSpans.0.scopeSpans.0.spans.0.kind', 0..5)
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.startTimeUnixNano', '^[0-9]+$')
        regex_comparison('resourceSpans.0.scopeSpans.0.spans.0.endTimeUnixNano', '^[0-9]+$')
        span_element_contains('resourceSpans.0.resource.attributes', 'device.id')
        each_span_element_contains('resourceSpans.0.scopeSpans.0.spans', 'attributes', 'bugsnag.sampling.p')
        span_element_contains('resourceSpans.0.resource.attributes', 'deployment.environment')
        span_element_contains('resourceSpans.0.resource.attributes', 'telemetry.sdk.name')
        span_element_contains('resourceSpans.0.resource.attributes', 'telemetry.sdk.version')
        validate_timestamp('resourceSpans.0.scopeSpans.0.spans.0.startTimeUnixNano', HOUR_TOLERANCE)
        validate_timestamp('resourceSpans.0.scopeSpans.0.spans.0.endTimeUnixNano', HOUR_TOLERANCE)
        element_a_greater_or_equal_element_b(
          'resourceSpans.0.scopeSpans.0.spans.0.endTimeUnixNano',
          'resourceSpans.0.scopeSpans.0.spans.0.startTimeUnixNano'
        )
      end

      def verify_against_schema
        if !@schema_errors.nil? && @schema_errors.size > 0
          @success = false
          @schema_errors.each do |error|
            @errors << "#{JSONSchemer::Errors.pretty(error)}"
          end
        end
      end

      # Checks that the required headers are present and correct
      def validate_headers
        # API key
        validate_header('bugsnag-api-key') do |api_key|
          expected = Regexp.new(HEX_STRING_32)
          unless expected.match(api_key)
            @success = false
            @errors << "bugsnag-api-key header was expected to match the regex '#{HEX_STRING_32}', but was '#{api_key}'"
          end
        end

        # Bugsnag-Sent-at
        validate_header('bugsnag-sent-at') do |date|
          begin
            Date.iso8601(date)
          rescue Date::Error
            @success = false
            @errors << "bugsnag-sent-at header was expected to be an IOS 8601 date, but was '#{date}'"
          end
        end

        # Bugsnag-Span-Sampling
        # of the format x:y where x is a decimal between 0 and 1 (inclusive) and y is the number of spans in the batch (if possible at this stage - we could weaken this if necessary)
        unless Maze.config.unmanaged_traces_mode
          validate_header('bugsnag-span-sampling') do |sampling|
            begin
              expected = Regexp.new(SAMPLING_HEADER)
              unless expected.match(sampling)
                @success = false
                @errors << "bugsnag-span-sampling header was expected to match the regex '#{SAMPLING_HEADER}', but was '#{sampling}'"
              end
            end
          end
        end
      end

      def span_element_contains(path, key_value, value_type=nil, possible_values=nil)
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

      def each_span_element_contains(container_path, attribute_path, key_value)
        container = Maze::Helper.read_key_path(@body, container_path)
        if container.nil? || !container.kind_of?(Array)
          @success = false
          @errors << "Element '#{container_path}' was expected to be an array, was '#{container}'"
          return
        end
        container.each_with_index do |_item, index|
          span_element_contains("#{container_path}.#{index}.#{attribute_path}", key_value)
        end
      end
    end
  end
end
