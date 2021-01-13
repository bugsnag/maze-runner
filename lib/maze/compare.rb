# frozen_string_literal: true

module Maze
  # Routines for conducting comparisons
  module Compare
    # Provides a way to delivering results of element comparisons to test steps
    class Result
      # @!attribute [r] reasons
      #   @return [Array] An array of reasons for a comparison result
      attr_reader :reasons

      # @!attribute [w] equal
      #   @param [Boolean] Indicates if the comparison indicated the elements were equal
      attr_writer :equal

      # @!attribute [r] keys
      #   @return [Array] An array of keys checked
      attr_reader :keys

      # Creates the Result object
      def initialize
        @equal = true
        @keys = []
        @reasons = []
      end

      # Indicates if the values compared to produced this result were equal
      #
      # @return [Boolean] Whether the elements were equal
      def equal?
        @equal
      end

      # Returns the keys traversed in order to compare the end values
      #
      # @return [String] The keypath used in the test
      def keypath
        keys.length > 0 ? keys.reverse.join('.') : '<root>'
      end

      # Provides a standard assertion of equality, with standardised output
      def assert_equal
        assert(@equal, "The compared fields do not match:\n #{result.reasons.join('\n')}")
      end
    end

    class << self
      # Compares two objects for value equality, traversing to compare each
      # nested object.
      #
      # @param obj1 [Any] The first object to compare
      # @param obj2 [Any] The second object to compare
      # @param result [Result|nil] Optional. Used for comparing recursively
      #
      # @return [Result] The result of comparing the objects
      def value(obj1, obj2, result = nil)
        result ||= Result.new
        return result if obj1 == 'IGNORE'

        if obj1 == 'NUMBER'
          if obj2.is_a?(Numeric)
            return result
          else
            result.equal = false
            result.reasons << "A Number was expected, '#{obj2.class} received"
            return result
          end
        end

        unless obj1.class == obj2.class
          result.equal = false
          result.reasons << "Object types differ - expected '#{obj1.class}', received '#{obj2.class}'"
          return result
        end

        case obj1
        when Array
          array(obj1, obj2, result)
        when Hash
          hash(obj1, obj2, result)
        when String
          string(obj1, obj2, result)
        else
          result.reasons << "#{obj1} is not equal to #{obj2}" unless (result.equal = (obj1 == obj2))
        end
        result
      end

      # Compares two arrays for value equality, traversing and comparing each element.
      # Results are written to the given Result object.
      #
      # @param array1 [Array] The first array to compare
      # @param array2 [Array] The second array to compare
      # @param result [Result] The Result to store the results
      def array(array1, array2, result)
        unless array1.length == array2.length
          result.equal = false
          result.reasons << "Expected #{array1.length} items in array, received #{array2.length}"
          return
        end

        array1.each_with_index do |obj1, index|
          value(obj1, array2[index], result)
          unless result.equal?
            result.keys << index.to_s
            break
          end
        end
      end

      # Compares two hashes for value equality, traversing and comparing each key-value pair.
      # Results are written to the given Result object.
      #
      # @param hash1 [Hash] The first hash to compare
      # @param hash2 [Hash] The second hash to compare
      # @param result [Result] The Result to store the results
      def hash(hash1, hash2, result)
        unless hash1.keys.length == hash2.keys.length
          result.equal = false
          missing = hash1.keys - hash2.keys
          unexpected = hash2.keys - hash1.keys
          result.reasons << "Missing keys from hash: #{missing.join(',')}" unless missing.empty?
          result.reasons << "Unexpected keys in hash: #{unexpected.join(',')}" unless unexpected.empty?
          return
        end

        hash1.each do |key, value|
          value(value, hash2[key], result)
          unless result.equal?
            result.keys << key
            break
          end
        end
      end

      # Compares two strings, writing the results to the given Result object.
      #
      # @param template [String] The expected string
      # @param str2 [String] The string to compare
      # @param result [Result] The Result to store the results
      def string(template, str2, result)
        return if template == str2 || regex_match(template, str2)

        result.equal = false
        result.reasons << "'#{str2}' does not match '#{template}'"
      end

      # Matches a string against a regex
      #
      # @param template [String] The regex to test with
      # @param value [String] The value to test
      #
      # @return [Boolean] Whether the regex produced a match
      def regex_match(template, value)
        regex = template
        regex = "^#{regex}$" unless regex.start_with?('^') || regex.end_with?('$')
        value =~ /#{regex}/
      end
    end
  end
end
