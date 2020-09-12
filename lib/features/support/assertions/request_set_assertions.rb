# frozen_string_literal: true

require 'test/unit'

# Provides helper routines for checking sets of requests against values in a table.
class RequestSetAssertions
  class << self
    include Test::Unit::Assertions

    # Checks that a set of requests satisfy the properties expressed by the table given.
    #
    # @param requests [Hash[]] Requests to check
    # @param table [Cucumber::MultilineArgument::DataTable] Table of expected values, where:
    #   - headings can be provided as key paths (e.g. events.0.breadcrumbs.0.name)
    #   - table values can be written as "null" for nil
    def assert_requests_match(requests, table)
      matches = matching_rows requests, table
      return if matches.length == table.hashes.length

      # Not all matched - log diagnostic before failing assertion
      $logger.error "Only #{matches.length} of #{requests.length} matched:"
      $logger.info matches.keys.sort
      matches.sort.to_h.each do |row, request|
        $logger.info "#{table.rows[row]} matched by request element #{matches[request]}"
      end
      assert_equal(requests.length, matches.length, 'Not all requests matched a row in the table.')
    end

    # Given arrays of requests and table-based criteria, determines which rows of the table
    # are satisfied by one of the requests.  Where multiple rows in the table specify the same
    # criteria, there must be multiple requests provided to satisfy each.
    #
    # @param requests [Hash[]] Requests to check
    # @param table [Cucumber::MultilineArgument::DataTable] Table of expected values, where:
    #   - headings can be provided as key paths (e.g. events.0.breadcrumbs.0.name)
    #   - table values can be written as "null" for nil
    # @return [Hash] A hash of row to request indexes, indicating the first request matching each row.
    #   E.g. {0 => 2} means that the first row was satisfied by the 3rd request.
    def matching_rows(requests, table)
      request_count = requests.length
      assert_equal(table.hashes.length, requests.length, 'Number of requests do not match number of entries in table.')

      # iterate through each row in the table. exactly 1 request should match each row.
      row_to_request_matches = {}
      table.hashes.each_with_index do |row, row_index|
        requests.each_with_index do |request, request_index|
          # Skip if row already matched
          next if row_to_request_matches.values.include? request_index
          # Skip if no body in this request
          next unless request.key?(:body)
          next unless request_matches_row(request[:body], row)

          # Record the match
          row_to_request_matches[row_index] = request_index
        end
      end
      row_to_request_matches
    end

    def request_matches_row(body, row)
      row.each do |key, expected_value|
        obs_val = read_key_path(body, key)
        next if ('null'.eql? expected_value) && obs_val.nil? # Both are null/nil

        unless obs_val.nil?
          if expected_value[0] == '/' && expected_value[-1] == '/'
            # Treat as regexp
            regex = Regexp.new expected_value[1, expected_value.length - 2]
            next if regex.match? obs_val.to_s # Value matches regex
          elsif expected_value.eql? obs_val.to_s
            # Values match
            next
          end
        end

        # Match not found - return false
        return false
      end
      # All matched - return true
      true
    end
  end
end

