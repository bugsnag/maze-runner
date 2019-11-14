require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

namespace :test do
  Rake::TestTask.new(:integration) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList['test/integration/{**/,}*_test.rb']
  end
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList['test/*_test.rb']
  end
  desc "Run all tests"
  task :all => [:unit, :integration]
end

namespace :docs do
  task :prepare do
    `cp yard-config ~/.yard/config`
    Dir.mkdir("doc")
    Dir.chdir("doc") do
      `git init`
      `git remote add origin git@github.com:bugsnag/maze-runner.git`
      `git fetch`
      `git checkout gh-pages`
      `git pull`
    end
  end

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/features/**/*.rb']
    t.options = ['--tag', 'step_input:Step parameters', '--markup', 'markdown']
  end

  task :publish do
    Dir.chdir("doc") do
      `git add .`
      `git commit -m "Docs update"`
      `git push`
    end
  end

  task :build_and_publish do
    Rake::Task["docs:prepare"].invoke
    Rake::Task["docs:yard"].invoke
    Rake::Task["docs:publish"].invoke
  end
end

task :default => ["test:unit"]
