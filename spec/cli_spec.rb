require 'spec_helper'
require 'yaml'

log_file = File.join(File.dirname(__FILE__), 'output.txt')

cli_tests = Hash.new

cli_tests['template'] = [
  "hi_zabbix template_upload -c .config/.zabbix.yml  -f  'spec/files/Template_OS_Linux_Hadoop_1.8.0.xml'",
  "hi_zabbix template_upload -c .config/.zabbix.yml  -f  'spec/files/Template_Hadoop_DataNode_1.1.0.xml'"
]

describe 'hi_zabbix cli examples' do

  cli_tests.each do |type,commands|
    it "does #{type} commands" do
      commands.each do |command|
        expect(Kernel.system("bundle exec #{command} 2>&1 >> #{log_file}")).to eq(true)
      end
    end
  end
end
