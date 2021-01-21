# frozen_string_literal: true

module Maze
  # An abstraction for storing a list of requests (e.g. Errors, Sessions),
  # keeping track of the "current" request (i.e. the one being inspected).
  class RequestList
    def initialize
      @requests = []
      @current = 0
      @count = 0
    end

    def empty?
      @requests.empty?
    end

    # The number of unprocessed/remaining requests in the list (not the total number actually held)
    def size
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
      @requests.append request.clone
      @count += 1
    end

    # The current request
    def current
      @requests[@current] if @requests.size > @current
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

    # A frozen clone of all requests held, including those already processed
    def all
      @requests.clone.freeze
    end

    # Clears the list
    def clear
      @requests.clear
      @current = 0
      @count = 0
    end
  end
end
