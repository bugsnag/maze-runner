# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name    = 'bugsnag-maze-runner'
  spec.version = BugsnagMazeRunner::VERSION
  spec.authors = ['Delisa Mason']
  spec.email   = ['iskanamagus@gmail.com']
  spec.required_ruby_version = '>= 2.0.0'
  spec.description =
    %q{
    Automation steps and mock server to validate request payloads
    response.
    }
  spec.summary = 'Bugsnag API request validation harness'
  spec.license = 'MIT'
  spec.require_paths = ["lib"]
  spec.files = Dir.glob("{bin,lib}/**/*").select { |fn| File.file?(fn) }

  spec.executables = spec.files.grep(%r{^bin/[\w\-]+$}) { |f| File.basename(f) }

  spec.add_dependency "cucumber", "~> 3.1.0"
  spec.add_dependency "gherkin", "~> 5.1.0"
  spec.add_dependency "test-unit", "~> 3.2.0"
  spec.add_dependency "minitest", "~> 5.0"
  spec.add_dependency "os", "~> 1.0.0"

  # Pinned due to issues with 5.0.16-5.0.17
  spec.add_dependency "cucumber-expressions", "5.0.15"
  spec.add_dependency "rake", "~> 12.3.0"
  spec.add_dependency "curb", "~> 0.9.6"
  spec.add_dependency "selenium-webdriver", "~> 3.11"
  spec.add_dependency "appium_lib", "~> 10.2"

  spec.add_development_dependency "yard", "~> 0.9.1"
  spec.add_development_dependency "yard-cucumber", "~> 4.0.0"
end
