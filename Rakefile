require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'open3'

def run_command(command)
  exit_status = 0
  Open3.popen2e(command) do |stdin, stdout_stderr, wait_thr|
    output = []
    stdout_stderr.each do |line|
      output << line
    end

    exit_status = wait_thr.value.to_i
    if exit_status != 0
      output.each { |line| puts line }
      throw Exception.new("An error occurred running command: #{command}")
    end
  end
end

namespace :test do
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/integration/{**/,}*_test.rb']
  end
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList.new('test/**/*_test.rb') do |fl|
      fl.exclude(/integration/)
    end
  end
  desc 'Run all tests'
  task :all => [:unit, :integration]
end

namespace :docs do
  task :prepare do
    Dir.mkdir('doc')
    Dir.chdir('doc') do
      run_command 'git init'
      run_command 'git remote add origin https://github.com/bugsnag/maze-runner.git'
      run_command 'git fetch'
      run_command 'git checkout gh-pages'
      run_command 'git pull'
      run_command "echo https://#{ENV["DOCS_PUSH_TOKEN"]}:x-oauth-basic@github.com >> ~/.git-credentials"
      run_command "git config credential.helper 'store'"
      run_command "git config --global user.email 'notifiers@bugsnag.com'"
      run_command "git config --global user.name 'Bugsnag notifiers'"
    end
  end

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/features/**/*.rb']
    t.options = ['--tag', 'step_input:Step parameters', '--markup', 'markdown', '--markup-provider', 'redcarpet', '--readme', 'DOCS.md']
  end

  task :publish do
    Dir.chdir('doc') do
      run_command 'git add .'
      run_command "git commit -m 'Docs update'"
      run_command 'git push'
    end
  end

  task :build_and_publish do
    Rake::Task['docs:yard'].invoke
    Rake::Task['docs:publish'].invoke
  end
end

task :default => ['test:unit']
