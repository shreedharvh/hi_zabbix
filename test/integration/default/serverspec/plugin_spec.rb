require 'spec_helper'

describe 'hi-zabbix plugin' do
  context command('yum -y install libxml2 libxml2-devel patch git gcc xz-devel gcc-c++') do
    its(:exit_status) { should eq 0 }
  end
  context command('rpm -qa | grep chefdk* ;if [ $? -eq 1 ]; then rpm -ivh https://packages.chef.io/files/stable/chefdk/1.2.22/el/7/chefdk-1.2.22-1.el7.x86_64.rpm; fi') do
    its(:exit_status) { should eq 0 }
  end
  context command(' cd /tmp/kitchen/data;/opt/chefdk/embedded/bin/bundle install -j 4 && set +e ;/opt/chefdk/embedded/bin/bundle exec /opt/chefdk/embedded/bin/rspec --format documentation;/opt/chefdk/embedded/bin/bundle exec /opt/chefdk/embedded/bin/rspec --format documentation ') do
    its(:exit_status) { should eq 0 }
  end
end
