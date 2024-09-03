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
        # @param list [Array] An array of received requests
        # @param list_name [String] The name of the payload list for received requests
        def validate_payload_elements(list, list_name)
          # Test to see if a custom validator exists for the list
          if Maze.config.custom_validators&.key?(list_name)
            custom_validator = true
            validator_class = Maze::Schemas::ConfigValidator
          else
            custom_validator = false
            validator_class = case list_name
            when 'trace', 'traces'
              Maze::Schemas::TraceValidator
            when 'error', 'errors'
              Maze::Schemas::ErrorValidator
            else
              nil
            end
          end

          if validator_class
            validators = list.all.map do |request|
              # TODO: Implement generically in class and handle there?
              if custom_validator
                validator = validator_class.new(request, Maze.config.custom_validators[list_name])
              else
                validator = validator_class.new(request)
              end
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
