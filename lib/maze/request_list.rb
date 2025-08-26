# frozen_string_literal: true
require 'securerandom'

module Maze
  # An abstraction for storing a list of requests (e.g. Errors, Sessions),
  # keeping track of the "current" request (i.e. the one being inspected).
  class RequestList
    def initialize
      @requests = []
      @current = 0
      @count = 0
    end

    # The number of unprocessed/remaining requests in the list (not the total number actually held)
    def size_remaining
      @count
    end

    # The total number of requests received, including those already processed
    def size_all
      @requests.size
    end

    # Add a request to the list
    #
    # @param request The new request, from which a clone is made
    def add(request)
      clone = request.clone
      # UUID primarily used for commands, but no harm to set on everything
      clone[:uuid] = SecureRandom.uuid
      clone[:run_uuid] = Maze.run_uuid
      @requests.append clone
      @count += 1
    end

    # The current request
    def current
      @requests[@current] if @requests.size > @current
    end

    # The request at the given index
    def get(index)
      @requests[index] if @requests.size > index
    end

    # Peek at requests yet to be processed - i.e. from current onwards.  All requests are left visible in the list.
    # Returns an empty array if there are no requests outstanding.
    def remaining
      return [] if current.nil?

      @requests[@current..@requests.size]
    end

    # Moves to the next request, if there is one
    def next
      return if @current >= @requests.size

      @current += 1
      @count -= 1
    end

    # Moves to the end of the list
    def end
      @current = @requests.size
      @count = 0
    end

    # A frozen clone of all requests held, including those already processed
    def all
      @requests.clone.freeze
    end

    # Clears the list completely
    def clear
      @requests.clear
      @current = 0
      @count = 0
    end

    # Sorts the first `count` elements of the list by the Bugsnag-Sent-At header, if present in all of those elements
    def sort_by_sent_at!(count)
      return unless count > 1

      header = 'Bugsnag-Sent-At'
      sub_list = @requests[@current...@current + count]

      return if sub_list.any? { |r| r[:request][header].nil? }

      # Sort sublist by Bugsnag-Sent-At and overwrite in the main list
      sub_list.sort_by! { |r| DateTime.parse(r[:request][header]) }
      sub_list.each_with_index { |r, i| @requests[@current + i] = r }
    end

    # Sorts the remaining elements of the list by the request path, if present in all of those elements
    def sort_by_request_path!
      list = remaining

      return if list.any? { |r| r[:request].path.nil? }

      # Sort the list by request path and overwrite in the main list
      list.sort_by! { |r| r[:request].path }
      list.each_with_index { |r, i| @requests[@current + i] = r }
    end

    # Sorts the remaining elements of the list by the field given, if present in all of those elements
    def sort_by!(key_path)
      list = remaining

      # Sort the list and overwrite in the main list
      list.sort_by! { |r| Maze::Helper.read_key_path(r[:body], key_path) }
      list.each_with_index { |r, i| @requests[@current + i] = r }
    end
  end
end
