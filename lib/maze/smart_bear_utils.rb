# frozen_string_literal: true

module Maze
  # Utils supporting the BrowserStack device farm integration
  class SmartBearUtils
    class << self
      SB_READY_FILE = 'sb.ready'
      SB_KILL_FILE = 'sb.kill'

      # Starts the BitBar local tunnel
      # @param sb_local [String] path to the SBSecureTunnel binary
      # @param tunnel_name [String] Tunnel name
      # @param username [String] Username to start the tunnel with
      # @param access_key [String] CBT access key
      def start_local_tunnel(sb_local, tunnel_name, username, access_key)
        # Make sure the ready/kill files are already deleted
        File.delete(SB_READY_FILE) if File.exist?(SB_READY_FILE)
        File.delete(SB_KILL_FILE) if File.exist?(SB_KILL_FILE)

        $logger.info 'Starting CBT SBSecureTunnel'
        command = "#{sb_local} --username #{username} --authkey #{access_key} --acceptAllCerts " \
                  "--ready #{SB_READY_FILE} --tunnelname #{tunnel_name} --kill #{SB_KILL_FILE}"

        output = start_tunnel_thread(command)

        success = Maze::Wait.new(timeout: 30).until do
          File.exist?(SB_READY_FILE)
        end
        unless success
          $logger.error "Failed: #{output}"
        end
      end

      # Stops the local tunnel
      def stop_local_tunnel
        FileUtils.touch(SB_KILL_FILE)
        Maze::Wait.new(timeout: 30).until do
          !File.exist?(SB_READY_FILE)
        end
        File.delete(SB_READY_FILE) if File.exist?(SB_READY_FILE)
        File.delete(SB_KILL_FILE) if File.exist?(SB_KILL_FILE)
      end

      private

      def start_tunnel_thread(cmd)
        executor = lambda do
          Open3.popen2e(Maze::Runner.environment, cmd) do |_stdin, stdout_and_stderr, wait_thr|

            output = []
            stdout_and_stderr.each do |line|
              output << line
              $logger.debug('SBSecureTunnel') {line.chomp}
            end

            exit_status = wait_thr.value.to_i
            $logger.debug "Exit status: #{exit_status}"

            output.each { |line| $logger.warn('SBSecureTunnel') {line.chomp} } unless exit_status == 0

            return [output, exit_status]
          end
        end

        Thread.new(&executor)
      end
    end
  end
end
