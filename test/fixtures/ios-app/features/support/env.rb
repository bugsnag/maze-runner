# Configure app environment

run_command "bundle install"
run_command "pod install"
run_command "features/fixtures/build-app.sh"
