module Maze

  # A simple run/stop timer
  class Timer
    attr_accessor :total

    def initialize
      @started = 0
      @total = 0
      @running = false
    end

    def run
      raise 'Timer already running' if @running

      @started = Time.now
      @running = true
    end

    def stop
      raise 'Timer is not running' unless @running

      duration = Time.now - @started
      @total += duration
      @running = false
    end

    def reset
      @total = 0
      @running = false
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

    def report
      return if @timers.empty?

      $logger.info 'Timer totals:'
      @timers.sort.each do |name, timer|
        $logger.info "#{name}: #{timer.total}"
      end
    end
  end
end
