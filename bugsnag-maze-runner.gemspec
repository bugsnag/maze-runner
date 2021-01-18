lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/maze'

Gem::Specification.new do |spec|
  spec.name    = 'bugsnag-maze-runner'
  spec.version = Maze::VERSION
  spec.authors = ['Steve Kirkland']
  spec.email   = ['steve@bugsnag.com']
  spec.required_ruby_version = '>= 2.5.0'
  spec.description = 'Automation steps and mock server to validate' \
                     'request payloads response.'
  spec.summary = 'Bugsnag API request validation harness'
  spec.license = 'MIT'
  spec.require_paths = ['lib']
  spec.files = Dir.glob('{bin,lib}/**/*').select { |fn| File.file?(fn) }

  spec.executables = spec.files.grep(%r{^bin/[\w\-]+$}) { |f| File.basename(f) }

  spec.add_dependency 'cucumber', '~> 3.1.2'
  spec.add_dependency 'gherkin', '~> 5.1.0'
  spec.add_dependency 'minitest', '~> 5.0'
  spec.add_dependency 'os', '~> 1.0.0'
  spec.add_dependency 'test-unit', '~> 3.3.0'

  spec.add_dependency 'appium_lib', '~> 10.2'
  spec.add_dependency 'cucumber-expressions', '~> 6.0.0'
  spec.add_dependency 'curb', '~> 0.9.6'
  spec.add_dependency 'optimist', '~> 3.0.1'
  spec.add_dependency 'rake', '~> 12.3.3'
  spec.add_dependency 'selenium-webdriver', '~> 3.11'
  spec.add_dependency 'boring', '~> 0.1.0'

  spec.add_development_dependency 'markdown', '~> 1.2'
  spec.add_development_dependency 'mocha', '~> 1.8.0'
  spec.add_development_dependency 'redcarpet', '~> 3.5'
  spec.add_development_dependency 'yard', '~> 0.9.1'
  spec.add_development_dependency 'yard-cucumber', '~> 4.0.0'
end
