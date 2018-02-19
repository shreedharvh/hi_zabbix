require 'spec_helper'

describe 'HiZabbix::Common' do
  let (:comm_obj) { HiZabbix::Common.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxapi_obj) {instance_double(ZabbixApi)}
  let (:zbxconn_obj) { comm_obj.zabbix_connection('user', 'pwd')}
  let (:hostgroups) { ['Templates'] }

  describe '#zabbix_connection' do 
    subject { zbxconn_obj }

    let(:zabbix_obj) { double(ZabbixApi) }
    context 'when connection is successful' do
      before { allow(ZabbixApi).to receive(:connect).and_return(zbxapi_obj) }
      it 'returns the zabbixapi object' do
        expect(subject).to be(zbxapi_obj)
      end
    end

    context 'when invalid parameters are passed for zabbix connection' do
      let(:comm_obj) { HiZabbix::Common.new(YAML.load_file('spec/files/invalid_test_config.yml'))}
      before { allow(ZabbixApi).to receive(:connect).and_raise(Net::OpenTimeout) }
      it 'raises RuntimeError' do       
        expect { subject }.to raise_error(Net::OpenTimeout)
      end
    end
  end

  describe '#check_hostgroups' do
    let (:hostgroups_obj) {instance_double(ZabbixApi::HostGroups)}
    subject { comm_obj.check_hostgroups(zbxconn_obj, hostgroups) }

    before do
      allow(comm_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(zbxconn_obj).to receive(:hostgroups).and_return(hostgroups_obj)
      allow(hostgroups_obj).to receive(:get_id).and_return(1)
    end
    context 'when hostgroup is present in zabbix' do
      it 'returns hash' do
        expect(subject).to eql({:present=>['Templates'], :not_present=>[]})
      end
    end

    context 'when hostgroup is not present in zabbix ' do
    let (:hostgroups) { ['Templates111']}
      before  do
        allow(zbxapi_obj).to receive(:hostgroups).and_return(hostgroups_obj)
        allow(hostgroups_obj).to receive(:get_id).and_return(nil)
      end

      it 'returns hash' do
        expect(subject).to eql({:present=>[], :not_present=>['Templates111']})
      end
    end
  end

  describe '#hostdetails' do
    let (:host_name) { '0ac511bc-9552-2220-d6db-94aa92eae13e2.myhost' }
    subject { comm_obj.host_details(zbxconn_obj, host_name)}

    before { allow(comm_obj).to receive(:zabbix_connection).and_return(zbxapi_obj) }

    context 'when host is present in zabbix' do
      before { allow(zbxconn_obj).to receive(:query).and_return({}) }
      it 'returns a hash' do
        expect(subject).to be_kind_of(Hash)
      end
    end

    context 'when host is not present in zabbix' do
      before { allow(zbxconn_obj).to receive(:query).and_return([]) }
      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#hostgroupsdetails' do
    let(:hostgroup_name) {'Discovered hosts'}
    subject{ comm_obj.hostgroup_details(zbxconn_obj,hostgroup_name) }

    before { allow(comm_obj).to receive(:zabbix_connection).and_return(zbxapi_obj) }

    context 'when hostgroup is present in zabbix' do
      before { allow(zbxconn_obj).to receive(:query).and_return({}) }
      it 'returns a hash' do
        expect(subject).to be_kind_of(Hash)
      end
    end

    context 'when hostgroup is not present in zabbix' do
      before { allow(zbxconn_obj).to receive(:query).and_return([]) }
      it 'returns a emprty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#groupid' do
    let(:grpname) {'Zabbix administrators'}
    let (:usergroups_obj) {instance_double(ZabbixApi::Usergroups)}
    subject {comm_obj.groupid(zbxconn_obj, grpname)}

    before { allow(comm_obj).to receive(:zabbix_connection).and_return(zbxapi_obj) }

    context 'when group is present in zabbix' do
      before do
        allow(zbxconn_obj).to receive(:usergroups).and_return(usergroups_obj)
        allow(usergroups_obj).to receive(:get_id).and_return({})
      end
      it 'returns a hash' do
        expect(subject).to be_kind_of(Hash)
      end
    end

    context 'when group is not present in zabbix' do
      before do
        allow(zbxconn_obj).to receive(:usergroups).and_return(usergroups_obj)
        allow(usergroups_obj).to receive(:get_id).and_return([])
      end
      it 'returns a empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#user_details' do
    let (:_alias) { 'sh042423' }
    let (:user_obj) { instance_double(ZabbixApi::Users)}

    subject { comm_obj.user_details(zbxconn_obj, _alias) }

    before do
      allow(comm_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(zbxconn_obj).to receive(:users).and_return(user_obj)
    end

    context 'when user exists in zabbix' do
      before { allow(user_obj).to receive(:get).and_return({}) }
      it 'returns a hash' do
        expect(subject).to be_kind_of(Hash)
      end
    end

    context 'when user doesnt exist in zabbix' do
      before { allow(user_obj).to receive(:get).and_return([]) }
      it 'returns a empty array' do
        expect(subject).to be_empty
      end
    end
  end
end
