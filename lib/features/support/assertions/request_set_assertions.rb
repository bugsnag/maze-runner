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
      request_count = requests.count
      assert_equal(table.hashes.length, requests.length, 'Number of requests do not match number of entries in table.')

      # iterate through each row in the table. exactly 1 request should match each row.
      matches = []
      table.hashes.each do |row|
        requests.each do |request|
          # Skip if no body in this request
          next unless request.key?(:body)
          next unless request_matches_row(request[:body], row)

          # Record with row the request matched against
          matches << {
            body: request[:body],
            row: row
          }
        end
      end
      # if request_count != matches.length
      if request_count == matches.length
        # Log requests that matched
        $logger.error "#{matches.length} of #{request_count} requests matched"
        matches.each do |match|
          $logger.info "#{match[:row]} was matched by:"
          LogUtil.log_hash(Logger::Severity::INFO, match[:body])
        end
        $logger.info 'All requests checked:'
        requests.each_with_index do |request, index|
          $logger.info "Request #{index + 1} of #{requests.length}"
          LogUtil.log_hash Logger::Severity::INFO, request[:body]
        end
      end
      assert_equal(request_count, matches.length, 'Not all requests matched a row in the table.')
    end

    def request_matches_row(body, row)
      row.each do |key, expected_value|
        obs_val = read_key_path(body, key)
        next if ('null'.eql? expected_value) && obs_val.nil? # Both are null/nil

        unless obs_val.nil?
          if expected_value[0] == '/' && expected_value[-1] == '/'
            # Treat as regexp
            regex_string = expected_value[1, expected_value.length - 2]
            $logger.info "Building a regexp from #{regex_string}"
            regex = Regexp.new regex_string
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

