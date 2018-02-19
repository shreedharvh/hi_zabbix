# coding: UTF-8
require 'roll_out/rake_tasks'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'kitchen/cli'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# Integration tests. Kitchen.ci
namespace :integration do
  CONCURRENCY = 12

  task :set_vagrant, [:regex] do |t, args|
    ENV['KITCHEN_LOCAL_YAML'] = './.kitchen.yml'
  end

  task :set_openstack, [:regex] do |t, args|
    ENV['KITCHEN_LOCAL_YAML'] = './.kitchen.openstack.yml'
  end

  task :vagrant, [:regex] => :set_vagrant do |t, args|
    Kitchen::CLI.new([], destroy: 'always').test args[:regex]
  end

  task :openstack, [:regex] => :set_openstack do |t, args|
    Kitchen::CLI.new([], destroy: 'always').test args[:regex]
  end

  desc 'Run Test Kitchen with Vagrant'
  namespace :vagrant do
    task :list, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).list args[:regex]
    end

    task :login, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).login args[:regex]
    end

    task :create, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).create args[:regex]
    end

    task :converge, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).converge args[:regex]
    end

    task :setup, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).setup args[:regex]
    end

    task :verify, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).verify args[:regex]
    end

    task :destroy, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([]).destroy args[:regex]
    end

    task :test, [:regex] => :set_vagrant do |t, args|
      Kitchen::CLI.new([], destroy: 'always').test args[:regex]
    end
  end

  desc 'Run Test Kitchen with OpenStack'
  namespace :openstack do
    task :list, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY).list args[:regex]
    end

    task :login, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([]).login args[:regex]
    end

    task :create, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY).create args[:regex]
    end

    task :converge, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY).converge args[:regex]
    end

    task :setup, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY).setup args[:regex]
    end

    task :verify, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY).verify args[:regex]
    end

    task :destroy, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([]).destroy args[:regex]
    end

    task :test, [:regex] => :set_openstack do |t, args|
      Kitchen::CLI.new([], concurrency: CONCURRENCY, destroy: 'always').test args[:regex]
    end
  end
end

task default: ['integration:vagrant']
