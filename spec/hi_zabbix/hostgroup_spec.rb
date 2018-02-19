require 'spec_helper'

describe 'HiZabbix::Host' do
  let (:hostgroup_obj) { HiZabbix::Hostgroup.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxconn_obj) { hostgroup_obj.zabbix_connection('user', 'pwd') }
  let (:zbxapi_obj) {instance_double(ZabbixApi)}
  let (:hostgroups_obj) {instance_double(ZabbixApi::HostGroups)}
  let (:config_hash) {{"conf_file_path"=>"config.yml", "hostgroup"=>"a new host group"}}

  describe '#create_hostgroup' do
    subject { hostgroup_obj.create_hostgroup(zbxconn_obj,config_hash) }

    before do
      allow(hostgroup_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(zbxconn_obj).to receive(:hostgroups).and_return(hostgroups_obj)
      allow(hostgroups_obj).to receive(:create).and_return(1)
    end

    context 'when hostgroup is created successfully' do
      before do
        allow(hostgroup_obj).to receive(:hostgroup_details).and_return([])
      end
      it 'returns hostgroup id' do
        expect(zbxconn_obj).to receive_message_chain(:hostgroups, :create).and_return(Fixnum)
        subject
      end
    end

    context 'when hostgroup already exists' do
      before do
        allow(hostgroup_obj).to receive(:hostgroup_details).and_return(['name'=>'Discovered Hosts'])
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when unable to create hostgroup' do
      before do
        allow(hostgroup_obj).to receive(:hostgroup_details).and_return([])
        allow(hostgroups_obj).to receive(:create).and_raise(ZabbixApi::ApiError.new('Unable to create hostgroup'))
      end
      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end
  end
end
