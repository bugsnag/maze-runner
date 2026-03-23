# frozen_string_literal: true

require_relative 'config_validator'
require_relative 'error_validator'
require_relative 'trace_validator'

module Maze
  module Schemas

    # A general entry point for running validation with schemas and other validation methods
    class Validator

      class << self
        # Tests that payloads for a specific path pass any additional validation checks
        # Throws an AssertionFailedError with a list of issues on failure
        #
        # @param list [Maze::RequestList] An array of received requests
        # @param list_name [String] The name of the payload list for received requests
        def validate_payload_elements(list, list_name)
          # Test to see if a custom validator exists for the list
          custom_validator = Maze.config.custom_validators&.key?(list_name)

          if Maze.config.skipped_validators && Maze.config.skipped_validators[list_name]
            validator_class = false
          else
            validator_class = case list_name
            when 'trace', 'traces'
              Maze::Schemas::TraceValidator
            when 'error', 'errors'
              Maze::Schemas::ErrorValidator
            else
              nil
            end
          end

          list_validators = list.all.map do |request|
            payload_validators = []
            payload_validators << Maze::Schemas::ConfigValidator.new(request, Maze.config.custom_validators[list_name]) if custom_validator
            payload_validators << validator_class.new(request) if validator_class

            payload_validators.each { |validator| validator.validate }
            payload_validators
          end

          failing = false
          list_validators.each.with_index(1) do |validators, index|
            validators.each do |validator|
              unless validator.success
                failing = true
                $stdout.puts "\n"
                $stdout.puts "\e[31m--- #{list_name} #{index} failed validation with the following errors:\e[0m"
                validator.errors.each do |error|
                  $stdout.puts "\e[31m#{error}\e[0m"
                end
                $stdout.puts "\n"
              end
            end
          end
          raise Test::Unit::AssertionFailedError.new("One or more #{list_name} payloads failed validation.  A full list of the errors can be found above") if failing
        end
      end
    end
  end
end
