lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.metadata['allowed_push_host'] = 'https://bugsnag.jfrog.io/artifactory/api/gems/platforms-rubygems'
  spec.name = 'bugsnag-maze-runner'
  spec.version = BugsnagMazeRunner::VERSION
  spec.authors = ['Steve Kirkand']
  spec.email = ['steve@bugsnag.com']
  spec.required_ruby_version = '>= 2.0.0'
  spec.description =
    'Automation steps and mock server to validate request payloads response.'
  spec.summary = 'Bugsnag API request validation harness'
  spec.license = 'MIT'
  spec.require_paths = ['lib']
  spec.files = %w[
    bin/bugsnag-maze-runner
    bin/maze-runner
    bin/commands/init.rb
    bin/bugsnag-print-load-paths
    lib/features/scripts/await-android-emulator.sh
    lib/features/scripts/clear-android-app-data.sh
    lib/features/scripts/install-android-app.sh
    lib/features/scripts/launch-android-app.sh
    lib/features/scripts/launch-android-emulator.sh
    lib/features/steps/android_steps.rb
    lib/features/steps/automation_steps.rb
    lib/features/steps/error_reporting_steps.rb
    lib/features/steps/request_assertion_steps.rb
    lib/features/support/compare.rb
    lib/features/support/env.rb
    lib/features/support/docker.rb
    lib/version.rb
  ]
  spec.executables = spec.files.grep(%r{^bin/[\w\-]+$}) { |f| File.basename(f) }

  spec.add_dependency 'cucumber', '~> 3.1.0'
  spec.add_dependency 'minitest', '~> 5.0'
  spec.add_dependency 'os', '~> 1.0.0'
  spec.add_dependency 'rack', '~> 2.0.0'
  spec.add_dependency 'test-unit', '~> 3.2.0'

  # Pinned due to issues with 5.0.16-5.0.17
  spec.add_dependency 'cucumber-expressions', '5.0.15'
  spec.add_dependency 'rake', '~> 12.3.3'
end
