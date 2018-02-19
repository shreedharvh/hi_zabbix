require 'spec_helper'

describe 'HiZabbix::Host' do
  let (:host_obj) { HiZabbix::Host.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxconn_obj) { host_obj.zabbix_connection('user', 'pwd') }
  let (:zbxapi_obj) {instance_double(ZabbixApi)}
  let (:hosts) { instance_double(ZabbixApi::Hosts) }
  let (:hostgroups_obj) {instance_double(ZabbixApi::HostGroups)}
  let (:config_hash) {{"conf_file_path"=>"config.yml", "host_name"=>"some host", "hostgroup"=>"Discovered hosts", "ip"=>"127.0.0.1"}}

  describe '#create_host' do
    subject { host_obj.create_host(zbxconn_obj, config_hash) }

    before do
      allow(host_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(host_obj).to receive(:host_details).and_return([])
      allow(zbxconn_obj).to receive(:hosts).and_return(hosts)
      allow(hosts).to receive(:create).and_return(1)
      allow(zbxconn_obj).to receive(:hostgroups).and_return(hostgroups_obj)
      allow(hostgroups_obj).to receive(:get_id).and_return(1)
    end

    context 'when host is created successfully' do
      it 'returns hostid' do
        expect(subject).to be_kind_of(Fixnum)
      end
    end

    context 'when host already exists' do
      before do
        allow(host_obj).to receive(:host_details).and_return(['name'=>'0ac511bc-9552-2220-d6db-94aa92eae13e2.myhost'])
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when unable to create host' do
      before do
        allow(hosts).to receive(:create).and_raise(ZabbixApi::ApiError.new('Invalid Hostgroup'))
      end
      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end
  end
end
