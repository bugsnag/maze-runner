require 'rack'
require 'open3'
require 'webrick'
require 'json'

MOCK_API_PORT = 9291
SCRIPT_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "scripts"))

Before do
  stored_requests.clear
  @script_env = {'MOCK_API_PORT' => "#{MOCK_API_PORT}"}
  @pids = []
end

After do |scenario|
  kill_script

  if scenario.failed? && ENV['VERBOSE']
    # Begin: Any further output from failed scenarios
    Dir.mkdir(File.join(Dir.pwd, 'maze_output')) unless Dir.exists? File.join(Dir.pwd, 'maze_output')
    Dir.chdir(File.join(Dir.pwd, 'maze_output')) do
      filename = scenario.name + '.' + Time.now.strftime('%s') + '.json'
      File.open(filename, 'w+') do |file|
        requests_received = stored_requests.size
        request_list = {
          :requests_received => requests_received,
        }
        request_list[:requests] = stored_requests.map do |request|
          {
            :headers => request[:request].header,
            :body => request[:body],
            :uri => request[:request].request_uri
          }
        end

        file.write JSON.fast_generate(request_list, {
          :array_nl => "\n",
          :object_nl => "\n",
          :indent => "\t"
        })
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

    if ENV['VERBOSE']
      command = args.join(' ')
      puts "Running '#{command}'"
      `#{command}`
    else
      out_reader, out_writer = IO.pipe
      err_reader, err_writer = IO.pipe
      pid = Process.spawn(@script_env || {}, args.join(' '),
                          :out => out_writer.fileno,
                          :err => err_writer.fileno)
      Process.waitpid(pid, 0)
      unless $?.exitstatus == 0
        puts "Script failed (#{args}):"
        puts out_reader.gets
        puts err_reader.gets
        exit(1)
      end
    end
  end
end

def encode_query_params hash
  URI.encode_www_form hash
end

def set_script_env key, value
  @script_env[key] = value
end

def run_script script_path
  load_path = File.join(SCRIPT_PATH, script_path)
  load_path = File.join(Dir.pwd, script_path) unless File.exists? load_path
  if ENV['VERBOSE']
    puts "Running '#{load_path}'"
    pid = Process.spawn(@script_env, load_path)
  else
    pid = Process.spawn(@script_env, load_path, :out => '/dev/null', :err => '/dev/null')
  end
  Process.detach(pid)
  @pids << pid
end

def kill_script
  @pids.each {|p|
    begin
    Process.kill("HUP", p)
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
    stored_requests << {body: JSON.load(request.body()), request:request}
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
      Logger: WEBrick::Log.new("/dev/null"),
      AccessLog: [],
    )
    server.mount '/', Servlet
    server.start
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
