# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'hi_zabbix/version'

Gem::Specification.new do |s|
  s.name        = 'hi_zabbix'
  s.version     = HiZabbix::VERSION
  s.authors     = ['DL_CWx_ETS_BLR_OPS_ENG']
  s.email       = 'DL_CWx_ETS_BLR_OPS_ENG@cerner.com'
  s.summary     = 'hi_zabbix plugin for Healthe Intent Deployment'
  s.description = 'hi_zabbix plugin for Healthe Intent Deployment'

  s.files       = Dir['lib/**/*.rb', 'README.md']
  s.bindir        = 'exe'
  s.executables   = 'hi_zabbix'
  s.require_paths = ['lib']

  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_dependency 'zabbixapi', '~> 3.0.0'
  s.add_dependency 'nokogiri',  '~> 1.8.1'
  # newer versions of the chef omnibus installer do not include readline. so for now require this
  s.add_dependency 'rb-readline'
  s.add_dependency 'unf'
  s.add_dependency 'unf_ext'
  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'roll_out'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc', '~> 4.1'
  s.add_development_dependency 'chef', '~> 12.12'
  s.add_development_dependency 'berkshelf'
  s.add_development_dependency 'jira-ruby', '~> 1.2'
  s.add_development_dependency 'test-kitchen'
  s.add_development_dependency 'kitchen-openstack'
  s.add_development_dependency 'kitchen-vagrant'
  s.add_development_dependency 'chef-vault'
  s.add_development_dependency 'kitchen-sync'
  s.add_development_dependency 'rspec-rerun'
end
