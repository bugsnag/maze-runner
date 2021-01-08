# frozen_string_literal: true

require 'json'
require 'singleton'
require 'webrick'
require 'webrick/https'
require 'webrick/httpproxy'

module Maze
  # Provides the ability to run a proxy server, using the WEBrick proxy server.
  # Note that for an HTTPS proxy a self-signed certificate will be used.  If using curl, for example, this
  # means having to employ the --proxy-insecure option.
  class Proxy
    include Singleton

    # There are some constraints on the port from driving remote browsers on BrowserStack.
    # E.g. the ports/ranges that Safari will access on "localhost" urls are restricted to the following:
    #   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999 [ from https://stackoverflow.com/a/28678652 ]
    PORT = 9000

    def initialize
      @hosts = []
    end

    # Whether the proxy handled a request for the given host
    #
    # @param host [String] The destination host to test for
    def handled_host?(host)
      @hosts.include? host
    end

    # Whether the proxy server thread is running
    #
    def running?
      @thread&.alive?
    end

    # Starts the WEBrick proxy in a separate thread
    # If authentication if requested, then the credentials used are simply 'user' with 'password'.
    #
    # @param protocol [Symbol] :Http or Https
    # @param authenticated [Boolean] Whether basic authentication should be applied.
    def start(protocol, authenticated = false)
      @hosts.clear

      attempts = 0
      $logger.info 'Starting proxy server'
      loop do
        @thread = Thread.new do

          handler = proc do |req, res|
            req.header['host'].each { |host| @hosts.append(host) }
          end
          config = {
            Logger: $logger,
            Port: PORT,
            ProxyContentHandler: handler
          }

          # Setup protocol
          if protocol == :Http
            $logger.info 'Starting HTTP proxy'
          elsif protocol == :Https
            $logger.info 'Starting HTTPS proxy'
            cert_name = [
              %w[CN localhost]
            ]
            config[:SSLCertName] = cert_name
            config[:SSLEnable] = true
          else
            raise "Unsupported protocol #{protocol}: :Http and :Https are supported"
          end

          # Authentication required?
          if authenticated
            # Apache compatible Password manager
            htpasswd = WEBrick::HTTPAuth::Htpasswd.new File.expand_path('htpasswd', __dir__)
            htpasswd.set_passwd 'Proxy Realm', 'user', 'password'
            htpasswd.flush
            authenticator = WEBrick::HTTPAuth::ProxyBasicAuth.new Realm: 'Proxy Realm',
                                                                  UserDB: htpasswd
            config[:ProxyAuthProc] = authenticator.method(:authenticate).to_proc
          end

          # Crwate and start the proxy
          proxy = WEBrick::HTTPProxyServer.new config
          proxy.start
        rescue StandardError => e
          $logger.warn "Failed to start proxy server: #{e.message}"
        ensure
          proxy&.shutdown
        end

        # Need a short sleep here as a dying thread is still alive momentarily
        sleep 1
        break if running?

        # Bail out after 3 attempts
        attempts += 1
        raise 'Too many failed attempts to start proxy server' if attempts == 3

        # Failed to start - sleep before retrying
        $logger.info 'Retrying in 5 seconds'
        sleep 5
      end
    end

    # Stops the WEBrick proxy thread if it's running
    def stop
      @thread&.kill if @thread&.alive?
      @thread = nil
    end
  end
end
