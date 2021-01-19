# frozen_string_literal: true

require 'pty'
require 'logger'

# Basic shell that runs an Appium server on a separate thread
class LocalAppiumServer
  attr_reader :pid
  attr_reader :appium_thread
  class << self
    def start(address: '0.0.0.0', port: '4723')
      return if @pid
      command = "appium -a #{address} -p #{port}"
      @appium_thread = Thread.new do
        PTY.spawn(command) do |stdout, _stdin, pid|
          @pid = pid
          $logger.debug("Appium:#{@pid}") { 'Appium server started' }
          stdout.each do |line|
            $logger.debug("Appium:#{@pid}") { line }
          end
        end
      end
      at_exit do
        stop
      end

      # DIRTY SLEEP - REMOVE
      sleep 5
    end

    def running
      @pid ? true : false
    end

    def stop
      return unless running
      $logger.debug("Appium:#{@pid}") { 'Stopping appium server' }
      Process.kill('INT', @pid)
      @pid = nil
      @appium_thread.join
      @appium_thread = nil
    end
  end
end
