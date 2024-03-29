# frozen_string_literal: true

module Maze
  module Schemas

    # A general entry point for running validation with schemas and other validation methods
    class Validator

      class << self

        # Tests that payloads for a specific path have passed any schema checks implemented on receipt
        # Throws an AssertionFailedError with a list of issues on failure
        #
        # @param list [Array] An array of received requests
        # @param list_name [String] The name of the payload list for received requests
        def verify_against_schema(list, list_name)
          request_schema_results = list.all.map { |request| request[:schema_errors] }
          passed = true
          request_schema_results.each.with_index(1) do |schema_errors, index|
            next if schema_errors.nil?
            if schema_errors.size > 0
              passed = false
              $stdout.puts "\n"
              $stdout.puts "\e[31m--- #{list_name} #{index} failed validation:\e[0m"
              schema_errors.each do |error|
                $stdout.puts "\e[31m#{JSONSchemer::Errors.pretty(error)}\e[0m"
              end
              $stdout.puts "\n"
            end
          end

          unless passed
            raise Test::Unit::AssertionFailedError.new 'The received payloads did not match the endpoint schema.  A full list of the errors can be found above'
          end
        end

        # Tests that payloads for a specific path pass any additional validation checks
        # Throws an AssertionFailedError with a list of issues on failure
        #
        # @param list [Array] An array of received requests
        # @param list_name [String] The name of the payload list for received requests
        def validate_payload_elements(list, list_name)
          validator_class = case list_name
          when 'trace', 'traces'
            Maze::Schemas::TraceValidator
          else
            nil
          end

          if validator_class
            validators = list.all.map do |request|
              validator = validator_class.new(request)
              validator.validate
              validator
            end

            return if validators.all? { |validator| validator.success }
            validators.each.with_index(1) do |validator, index|
              unless validator.success
                $stdout.puts "\n"
                $stdout.puts "\e[31m--- #{list_name} #{index} failed validation with the following errors:\e[0m"
                validator.errors.each do |error|
                  $stdout.puts "\e[31m#{error}\e[0m"
                end
                $stdout.puts "\n"
              end
            end
            raise Test::Unit::AssertionFailedError.new("One or more #{list_name} payloads failed validation.  A full list of the errors can be found above")
          end
        end
      end
    end
  end
end
