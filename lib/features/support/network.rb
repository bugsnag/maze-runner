require 'socket'

MAX_MAZE_CONNECT_ATTEMPTS = ENV.include?('MAX_MAZE_CONNECT_ATTEMPTS')? ENV['MAX_MAZE_CONNECT_ATTEMPTS'].to_i : 100

class Network
  class << self
    def wait_for_port(host, port)
      attempts = 0
      up = false
      until (attempts >= MAX_MAZE_CONNECT_ATTEMPTS) || up
        attempts += 1
        up = port_open?(host, port)
        sleep 0.1 unless up
      end
      raise "Port not ready in time!" unless up
    end

    def port_open?(host, port, seconds=0.1)
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new(host, port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
          false
        end
      end
    rescue Timeout::Error
      false
    end
  end
end