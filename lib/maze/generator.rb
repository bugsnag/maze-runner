# A thread-safe generator of values, backed by an Enumerator.
module Maze
  class Generator
    def initialize(enumerator)
      # A SizedQueue allows a set number of values to always be ready for clients
      # and will be automatically topped up from the enumerator.
      @queue = SizedQueue.new(10)

      # The queue filler continually adds to the queue (when there is room), taking
      # values from the Enumerator.  This ensure the enumerator is always run inside
      # the same thread
      @queue_filler = create_queue_filler(enumerator)

      while @queue.empty? && enumerator.size != 0
        # Wait for the queue to start filling
      end
    end

    # Get the next value
    #
    # @return The next value
    def next
      @queue.pop
    end

    def empty?
      @queue.empty?
    end

    private

    # Create a thread that will constantly append to @queue with values from the
    # given enumerator
    #
    # @param enumerator [Enumerator]
    # @return [Thread]
    def create_queue_filler(enumerator)
      # By passing the enumerator as an argument to Thread.new, it creates a copy
      # local to that thread and therefore we're not sharing an enumerator across
      # threads
      Thread.new(enumerator) do |status_code_generator|
        loop do
          # Add to the queue until it fills up, this will then block until there's
          # room in the queue again
          @queue << status_code_generator.next
        end
      end
    end
  end
end
