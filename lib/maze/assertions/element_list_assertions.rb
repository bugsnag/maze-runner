require 'test/unit'
require_relative '../helper'

module Maze
  module Assertions

    # Acts as shortcuts for declaring the assertion type
    EQUALS = 'equals'
    REGEX = 'regex'
    EXISTS = 'exists'
    COMPARE = 'compare'

    # Acts as shortcuts for declaring how to compare two values
    GREATER = 'greater'
    LESSER = 'lesser'
    EQUAL = 'equal'
    NOT_EQUAL = 'not_equal'

    # Provides help to verify many elements of a request with a single combined output.
    class ElementListAssertions
      class << self
        # Checks that a given request matches all elements in a list of assertions.
        #
        # Each assertion must be a hash containing:
        #   element: A string path to an element in the request
        #   type: The type of assertion that should be used to match the element and given value
        #   value: The value to assert against, or a second element if this is a comparison
        #   comparison: The type of comparison to use (optional)
        #
        # @param request [Hash] The request body to test against
        # @param assertions [Array] An array of assertions to test the request against
        def assert_elements_match(request, assertions)
          errors = []
          assertions.each do |assertion|
            begin
              case assertion[:type]
              when EQUALS
                equals_assertion(request, assertion, errors)
              when REGEX
                regex_assertion(request, assertion, errors)
              when EXISTS
                exists_assertion(request, assertion, errors)
              when COMPARE
                comparison_assertion(request, assertion, errors)
              else
                errors << {
                  assertion: assertion,
                  error: "The assertion type #{assertion[:type]} is invalid"
                }
              end
            rescue => error
              errors << {
                assertion: assertion,
                error: error
              }
            end
          end

          output_errors(errors) unless errors.empty?
        end

        # Outputs all errors captured during assertions and raises a test-terminating error.
        #
        # @param errors [Array] The array of errors from tests to output
        def output_errors(errors)
          error_string = ""
          errors.each do |error|
            error_string << "#{error[:error]}\n"
          end
          raise RuntimeError.new(error_string)
        end

        # Asserts that an element at a given path is equal to a given value.
        #
        # @param request [Hash] The request body to test against
        # @param assertion [Hash] A hash containing the elements for the test
        # @param error [Array] An array of errors to be checked after all tests
        def equals_assertion(request, assertion, errors)
          element_value = Maze::Helper.read_key_path(request, assertion[:element])
          unless element_value.eql?(assertion[:value])
            errors << {
              assertion: assertion,
              error: "Element #{assertion[:element]} was expected to be #{assertion[:value]}, but was #{element_value}"
            }
          end
        end

        # Asserts that an element at a given path matches a given regex.
        #
        # @param request [Hash] The request body to test against
        # @param assertion [Hash] A hash containing the elements for the test
        # @param error [Array] An array of errors to be checked after all tests
        def regex_assertion(request, assertion, errors)
          element_value = Maze::Helper.read_key_path(request, assertion[:element])
          if assertion[:value].nil?
            errors << {
              assertion: assertion,
              error: "Regex comparison for element #{assertion[:element]} must have a valid regex"
            }
            return
          end
          expected = Regexp.new(assertion[:value])
          unless expected.match(element_value)
            errors << {
              assertion: assertion,
              error: "Element #{assertion[:element]} was expected to match the regex #{assertion[:value]}, but was #{element_value}"
            }
          end
        end

        # Asserts that an element at a given path is not null.
        #
        # @param request [Hash] The request body to test against
        # @param assertion [Hash] A hash containing the elements for the test
        # @param error [Array] An array of errors to be checked after all tests
        def exists_assertion(request, assertion, errors)
          element_value = Maze::Helper.read_key_path(request, assertion[:element])
          if element_value.nil?
            errors << {
              assertion: assertion,
              error: "Element #{assertion[:element]} was expected to be non-null"
            }
          end
        end

        # Asserts that two elements at given paths relate in the specified way.
        #
        # The comparisons that can be used are:
        #  - greater: The value at the element path is larger than the value at the value path
        #  - lesser: The value at the element path is smaller than the value at the value path
        #  - equal: The values at the element and value paths are equal
        #  - not_equal: The values at the element and value paths are not equal
        #
        # @param request [Hash] The request body to test against
        # @param assertion [Hash] A hash containing the elements for the test
        # @param error [Array] An array of errors to be checked after all tests
        def comparison_assertion(request, assertion, errors)
          element_value = Maze::Helper.read_key_path(request, assertion[:element])
          compare_value = Maze::Helper.read_key_path(request, assertion[:value])
          valid = case assertion[:comparison]
          when GREATER
            element_value > compare_value
          when LESSER
            element_value < compare_value
          when EQUAL
            element_value == compare_value
          when NOT_EQUAL
            element_value != compare_value
          else
            false
          end
          unless valid
            errors << {
              assertion: assertion,
              error: "Element #{assertion[:element]}, #{element_value} was expected to be #{assertion[:comparison]} compared to #{assertion[:value]},#{compare_value}"
            }
          end
        end
      end
    end
  end
end
