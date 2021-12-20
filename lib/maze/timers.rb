module Maze

  # A simple run/stop timer
  class Timer
    attr_accessor :total

    def initialize
      @started = 0
      @total = 0
    end

    def time(&block)
      start = Time.now

      block.call
    ensure
      @total += Time.now - start
    end

    def reset
      @total = 0
    end
  end

  # Stores a collection of timers
  class Timers
    def initialize
      @timers = {}
    end

    def add(name)
      timer = Timer.new
      @timers[name] = timer
      timer
    end

    def get(name)
      @timers[name]
    end

    def size
      @timers.size
    end

    def report
      $logger.info 'Timer totals:'
      @timers.sort.each do |name, timer|
        $logger.info "  #{name}: #{timer.total}"
      end
    end
  end
end
