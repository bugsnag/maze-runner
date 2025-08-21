lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/maze'

Gem::Specification.new do |spec|
  ruby_version = Gem::Version.new(RUBY_VERSION.dup)

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

  if ruby_version < Gem::Version.new('3.0.0')
    spec.add_dependency 'ffi', '1.16.3'
  end

  spec.add_dependency 'cucumber', '~> 7.1'
  spec.add_dependency 'os', '~> 1.0.0'
  spec.add_dependency 'test-unit', '~> 3.5.2'
  spec.add_dependency 'rack', '~> 2.2'
  spec.add_dependency 'webrick', '~> 1.7.0'

  # Appium 12/Selenium 4 enforce the use of W3C
  if ENV['USE_LEGACY_DRIVER']
    puts 'Bundling legacy drivers (Selenium 3/Appium 11)'
    spec.add_dependency 'appium_lib', '~> 11.0'
    spec.add_dependency 'selenium-webdriver', '~> 3.0'
  else
    puts 'Bundling W3C drivers (Selenium 4/Appium 12)'
    spec.add_dependency 'appium_lib', '~> 12.0.0'
    spec.add_dependency 'appium_lib_core', '~> 5.4.0'
    spec.add_dependency 'selenium-webdriver', '~> 4.0'
  end

  spec.add_dependency 'bugsnag', '~> 6.24'
  spec.add_dependency 'cucumber-expressions', '~> 6.0.0'
  spec.add_dependency 'curb', '~> 1.0.5'
  spec.add_dependency 'dogstatsd-ruby', '~> 5.5.0'
  spec.add_dependency 'datadog_api_client', '2.40.0'
  spec.add_dependency 'optimist', '~> 3.0.1'
  spec.add_dependency 'rake', '~> 12.3.3'
  spec.add_dependency 'json_schemer', '~> 0.2.24'

  # Pin indirect dependencies
  spec.add_runtime_dependency 'rubyzip', '~> 2.3.2'

  # Dependencies no longer part of the standard library
  spec.add_runtime_dependency 'ostruct', '~>0.6.0'
  spec.add_runtime_dependency 'logger', '~>1.6'
  spec.add_runtime_dependency 'base64', '~>0.2.0'
  spec.add_runtime_dependency 'bigdecimal', '~>3.1'

  spec.add_development_dependency 'license_finder', '~> 7.0'
  spec.add_development_dependency 'markdown', '~> 1.2'
  spec.add_development_dependency 'mocha', '~> 1.13.0'
  spec.add_development_dependency 'redcarpet', '~> 3.5'
  spec.add_development_dependency 'yard', '~> 0.9.1'
  spec.add_development_dependency 'timecop', '~> 0.9.6'
end
