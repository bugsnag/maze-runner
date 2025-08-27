require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yard'
require 'open3'
require 'net/http'
require 'json'

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

def parse_release_tag(tag)
  regex = /^[vV]?(\d+)\.(\d+)\.(\d+).*$/
  parsed = regex.match(tag)
  {
    major: parsed[1].to_i,
    minor: parsed[2].to_i,
    patch: parsed[3].to_i
  }
end

def version_greater_than(tag1, tag2)
  if tag1[:major].eql?(tag2[:major])
    if tag1[:minor].eql?(tag2[:minor])
      tag1[:patch] > tag2[:patch]
    else
      tag1[:minor] > tag2[:minor]
    end
  else
    tag1[:major] > tag2[:major]
  end
end

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList.new('test/**/*_test.rb')
  end
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
      run_command "echo https://#{ENV["MAZE_DOCS_PUSH_TOKEN"]}:x-oauth-basic@github.com >> ~/.git-credentials"
      run_command "git config credential.helper 'store'"
      run_command "git config --global user.email 'notifiers@bugsnag.com'"
      run_command "git config --global user.name 'Bugsnag notifiers'"
    end
  end

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/features/**/*.rb']
    t.options = ['--tag', 'step_input:Step parameters', '--markup', 'markdown', '--markup-provider', 'redcarpet']
  end

  task :publish do
    Dir.chdir('doc') do
      run_command 'git add .'
      run_command "git commit -m 'Docs update'"
      run_command 'git push'
    end
  end

  task :build_and_publish do
    latest_release_raw = Net::HTTP.get(URI('https://api.github.com/repos/bugsnag/maze-runner/releases/latest'))
    latest_release = JSON.parse(latest_release_raw)
    latest_version = latest_release['tag_name']

    latest_tag = parse_release_tag(latest_version)
    release_tag = parse_release_tag(ENV['BUILDKITE_TAG'])

    if release_tag.eql?(latest_tag) || version_greater_than(release_tag, latest_tag)
      Rake::Task['docs:yard'].invoke
      Rake::Task['docs:publish'].invoke
    else
      puts 'Skipping docs publish as the tag is not the latest release'
    end
  end
end

task :default => ['test:unit']
