require 'rack'
require 'open3'
require 'net/http'
require 'webrick'
require 'json'
require 'test/unit'
include Test::Unit::Assertions

# This port number is semi-arbitrary. It doesn't matter for the sake of
# the application what it is, but there are some constraints due to some
# of the environments that we know this will be used in – namely, driving
# remote browsers on BrowserStack. The ports/ranges that Safari will access
# on "localhost" urls are restricted to the following:
#
#   80, 3000, 4000, 5000, 8000, 8080 or 9000-9999
#   [ from https://stackoverflow.com/a/28678652 ]
#
MOCK_API_PORT = 9339

SCRIPT_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "scripts"))
FAILED_SCENARIO_OUTPUT_PATH = File.join(Dir.pwd, 'maze_output')
DEV_NULL = Gem.win_platform? ? 'NUL' : '/dev/null'

Before do
  stored_requests.clear
  find_default_docker_compose
  clear_docker_services
  @script_env = {'MOCK_API_PORT' => "#{MOCK_API_PORT}"}
  @pids = []
  if @thread and not @thread.alive?
    puts "Mock server is not running on #{MOCK_API_PORT}"
    exit(1)
  end
end

After do |scenario|
  kill_script

  if scenario.failed?
    write_failed_requests_to_disk(scenario)
    output_logs if defined? output_logs
  end
end

def write_failed_requests_to_disk(scenario)
  Dir.mkdir(FAILED_SCENARIO_OUTPUT_PATH) unless Dir.exists? FAILED_SCENARIO_OUTPUT_PATH
  Dir.chdir(FAILED_SCENARIO_OUTPUT_PATH) do
    date = DateTime.now.strftime('%d%m%y%H%M%S%L')
    stored_requests.each_with_index do |request, i|
      filename = "#{scenario.name}-request#{i}-#{date}.log"
      File.open(filename, 'w+') do |file|
        file.puts "URI: #{request[:request].request_uri}"
        file.puts "HEADERS:"
        request[:request].header.each do |key, values|
          file.puts "  #{key}: #{values.map {|v| "'#{v}'"}.join(' ')}"
        end
        file.puts
        file.puts "BODY:"
        file.puts JSON.pretty_generate(request[:body])
      end
    end
  end
end

# Run each command synchronously, printing output only in the event of failure
# and exiting the program
def run_required_commands command_arrays
  command_arrays.each do |args|
    internal_script_path = File.join(SCRIPT_PATH, args.first)
    args[0] = internal_script_path if File.exists? internal_script_path
    command = args.join(' ')

    if ENV['VERBOSE']
      puts "Running '#{command}'"
      out_reader, out_writer = nil, STDOUT
    else
      out_reader, out_writer = IO.pipe
    end

    pid = Process.spawn(@script_env || {}, command,
                        :out => out_writer.fileno,
                        :err => out_writer.fileno)
    Process.waitpid(pid, 0)
    unless ENV['VERBOSE']
      out_writer.close
    end
    unless $?.exitstatus == 0
      puts "Script failed (#{command}):"
      puts out_reader.gets if out_reader and not out_reader.eof?
      exit(1)
    end
  end
end

def current_ip
  if OS.mac?
    'host.docker.internal'
  else
    ip_addr = `ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\\.){3}[0-9]*' | grep -v '127.0.0.1'`
    ip_list = /((?:[0-9]*\.){3}[0-9]*)/.match(ip_addr)
    ip_list.captures.first
  end
end

def wait_for_response(port)
  max_attempts = ENV.include?('MAX_MAZE_CONNECT_ATTEMPTS')? ENV['MAX_MAZE_CONNECT_ATTEMPTS'].to_i : 10
  attempts = 0
  up = false
  until (attempts >= max_attempts) || up
    attempts += 1
    begin
      uri = URI("http://localhost:#{port}/")
      response = Net::HTTP.get_response(uri)
      up = (response.code == "200")
    rescue EOFError
    end
    sleep 1
  end
  raise "App not ready in time!" unless up
end

def encode_query_params hash
  URI.encode_www_form hash
end

def run_command(*cmd, must_pass: true)
  STDOUT.puts cmd if ENV['VERBOSE']
  stdout, stderr, status = Open3.capture3(*cmd)
  STDOUT.puts stdout if ENV['VERBOSE']
  STDOUT.puts stderr if ENV['VERBOSE']

  assert_true(status.success?) if must_pass

  stdout.split("\n")
end

def set_script_env key, value
  @script_env[key] = value
end

def run_script script_path
  load_path = File.join(SCRIPT_PATH, script_path)
  load_path = File.join(Dir.pwd, script_path) unless File.exists? load_path
  if Gem.win_platform?
    # windows does not support the shebang that we use in the scripts so it
    # needs to know how to execute the script. Passing `cmd /c` tells windows
    # to use it's known file associations to execute this path. If ruby is
    # installed on windows then it will know that `rb` files should be exceuted
    # using ruby etc.
    load_path = "cmd /c #{load_path}"
  end
  if ENV['VERBOSE']
    puts "Running '#{load_path}'"
    pid = Process.spawn(@script_env, load_path)
  else
    pid = Process.spawn(@script_env, load_path, :out => DEV_NULL, :err => DEV_NULL)
  end
  Process.detach(pid)
  @pids << pid
end

def kill_script
  @pids.each {|p|
    begin
    Process.kill("KILL", p)
    rescue Errno::ESRCH
    end
  }
end

def load_event request_index=0, event_index=0
  stored_requests[request_index][:body]["events"][event_index]
end

def stored_requests
  $requests ||= []
end

def read_key_path hash, key_path
  value = hash
  key_path.split('.').each do |key|
    if key =~ /^(\d+)$/
      key = key.to_i
      if value.length > key
        value = value[key.to_i]
      else
        return nil
      end
    else
      if value.keys.include? key
        value = value[key]
      else
        return nil
      end
    end
  end
  value
end


class Servlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST request, response
    case request['Content-Type']
    when /^multipart\/form-data; boundary=([^;]+)/
      boundary = WEBrick::HTTPUtils::dequote($1)
      body = WEBrick::HTTPUtils.parse_form_data(request.body(), boundary)
      stored_requests << {body: body, request: request}
    else
      # "content-type" is assumed to be JSON (which mimicks the behaviour of
      # the actual API). This supports browsers that can't set this header for
      # cross-domain requests (IE8/9)
      stored_requests << {body: JSON.load(request.body()), request:request}
    end
    response.header['Access-Control-Allow-Origin'] = '*'
    response.status = 200
  end

  def do_OPTIONS request, response
    response.header['Access-Control-Allow-Origin'] = '*'
    response.header['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
    response.header['Access-Control-Allow-Headers'] = 'Origin,Content-Type,Bugsnag-Sent-At,Bugsnag-Api-Key,Bugsnag-Payload-Version,Accept'
    response.status = 200
  end
end

def start_server
  @thread = Thread.new do
    server = WEBrick::HTTPServer.new(
      :Port => MOCK_API_PORT,
      Logger: WEBrick::Log.new(DEV_NULL),
      AccessLog: [],
    )
    server.mount '/', Servlet
    begin
      server.start
    ensure
      server.shutdown
    end
  end
end

def stop_server
  @thread.kill if @thread and @thread.alive?
  @thread = nil
end

start_server

at_exit do
  stop_server
end
