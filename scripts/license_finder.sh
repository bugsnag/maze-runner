#!/bin/bash
curl https://raw.githubusercontent.com/bugsnag/license-audit/master/config/decision_files/global.yml -o config/global.yml
bundle install
gem install license_finder --no-document
license_finder --decisions-file=config/global.yml
