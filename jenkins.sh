#!/bin/bash

# exit on first error
set -e
# enable bash debug
set -x

# ensure we are clean from the previous testing run
rm -f Gemfile.lock Berksfile.lock
# install gem dependencies
bundle install
bundle exec kitchen create default-rhel72 -d always -c 4 --no-color
bundle exec kitchen converge default-rhel72 -d always -c 4 --no-color
bundle exec kitchen verify default-rhel72 -d always -c 4 --no-color
set +e
bundle exec rspec 
# execute twice as few tests may fail for the first run
set -e
bundle exec rspec
bundle exec kitchen destroy
