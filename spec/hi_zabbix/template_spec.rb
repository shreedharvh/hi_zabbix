require 'spec_helper'

describe 'HiZabbix::Template' do
  let (:template_obj) { HiZabbix::Template.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxconn_obj) { template_obj.zabbix_connection('user', 'pwd') }
  let (:zbxconf) {instance_double('ZabbixApi:Configurations')}
  let (:tempfile) { File.expand_path("spec/files/Template_Hadoop_DataNode_1.1.0.xml") }
  let (:zbxapi_obj) {instance_double(ZabbixApi)}
  
  describe '#template_upload' do
    subject { template_obj.template_upload(zbxconn_obj, tempfile) }

    before do
      allow(template_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(template_obj).to receive(:check_hostgroups).and_return({ present: [], not_present: [] })
    end

    context 'when successfully uploads template' do      
      before do
        allow(zbxconn_obj).to receive(:configurations).and_return(zbxconf)
        allow(zbxconf).to receive(:import).and_return(true)
      end
      it 'return true' do      
        expect(subject).to be(true) 
      end
    end

    context 'when fails to upload template' do
      let (:tempfile) { File.expand_path("spec/files/Template_OS_Linux_Hadoop_1.8.0.xml") }
      before do
        allow(zbxconn_obj).to receive(:configurations).and_return(zbxconf)
        allow(zbxconf).to receive(:import).and_raise(ZabbixApi::ApiError.new('Unable to upload template'))
      end
      it 'returns ' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end
  end
end
