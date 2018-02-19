require 'spec_helper'

describe 'HiZabbix::Maintenance' do
  let (:user_obj) { HiZabbix::Maintenance.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxconn_obj) { user_obj.zabbix_connection('user','pwd') }
  let (:zbxapi_obj) {instance_double(ZabbixApi)}
  let (:config_hash) {{"host"=>"0ac511bc-9552-2220-d6db-94aa92eae13e2.myhost", "hostgroup"=>"Discovered hosts", "duration"=>"3600", "conf_file_path"=>"config.yml"}}
  let (:jira_number) {'etsdev-3965'}

  before do
    allow(user_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
  end

  describe '#create maintenance' do
    subject { user_obj.create_maintenance(zbxconn_obj, config_hash, jira_number) }
    before do 
      allow(user_obj).to receive(:host_details).and_return([{'hostid'=>'50501'}])
      allow(user_obj).to receive(:hostgroup_details).and_return([{'groupid'=>'5'}])
      allow(user_obj).to receive(:maintenance_details).and_return([])
    end

    context 'when maintenance window is created successfully' do
      it 'return maintenance id' do
        expect(zbxconn_obj).to receive(:query).and_return(Fixnum)
        subject
      end
    end

    context 'when unable to create maintenance window' do
      before do
        allow(user_obj).to receive(:host_details).and_return([{'name' => 'somehost', 'hostid' => '111'}])
        allow(user_obj).to receive(:hostgroup_details).and_return([{'name' => 'somehostgroup', 'groupid' => '777'}])
        allow(user_obj).to receive(:maintenance_details).and_return({})
        allow(zbxconn_obj).to receive(:query).and_raise(ZabbixApi::ApiError.new('Unable to create maintenance'))
      end

      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end

    context 'when host doesn\'t exists' do
      before do
        allow(user_obj).to receive(:host_details).and_return({}) 
        allow(user_obj).to receive(:hostgroup_details).and_return([{'name' => 'somehostgroup', 'groupid' => '777'}])
        allow(zbxconn_obj).to receive(:query).and_return([{ 'maintenanceids' => ['1234'] }])
      end

      it 'returns nil' do
        expect(subject).to be_kind_of Array
      end
    end

    context 'when hostgroup doesn\'t exists' do
      before do 
        allow(user_obj).to receive(:hostgroup_details).and_return({})
        allow(user_obj).to receive(:host_details).and_return([{'name' => 'somehost', 'hostid' => '111'}])
        allow(zbxconn_obj).to receive(:query).and_return([{ 'maintenanceids' => ['1234'] }])
      end

      it 'returns nil' do
        expect(subject).to be_kind_of Array
      end
    end

    context 'when maintenance window already exists' do
      before { allow(user_obj).to receive(:maintenance_details).and_return([{}]) }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#update maintenance' do
    subject { user_obj.update_maintenance(zbxconn_obj, config_hash, jira_number) }
    before do
      allow(user_obj).to receive(:host_details).and_return(['hostid'=>'50501'])
      allow(user_obj).to receive(:hostgroup_details).and_return(['groupid'=>'5'])
      allow(user_obj).to receive(:maintenance_details).and_return(['maintenanceid'=>'27'])
    end

    context 'when maintenance window is updated successfully' do
      it 'return maintenance id' do
        expect(zbxconn_obj).to receive(:query).and_return([{}])
        subject
      end
    end

    context 'when unable to update maintenance window' do
      before { allow(zbxconn_obj).to receive(:query).and_raise(ZabbixApi::ApiError.new('Unable to update maintenance')) }

      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end

    context 'when host doesn\'t exists' do
      before do
        allow(user_obj).to receive(:host_details).and_return({}) 
        allow(user_obj).to receive(:hostgroup_details).and_return([{'name' => 'somehostgroup', 'groupid' => '777'}])
        allow(zbxconn_obj).to receive(:query).and_return([{ 'maintenanceids' => ['1234'] }])
      end

      it 'returns nil' do
        expect(subject).to be_kind_of Array
      end
    end

    context 'when hostgroup doesn\'t exists' do
      before do 
        allow(user_obj).to receive(:hostgroup_details).and_return({})
        allow(user_obj).to receive(:host_details).and_return([{'name' => 'somehost', 'hostid' => '111'}])
        allow(zbxconn_obj).to receive(:query).and_return([{ 'maintenanceids' => ['1234'] }])
      end

      it 'returns nil' do
        expect(subject).to be_kind_of Array
      end
    end

    context 'when maintenance window doesn\'t exists' do
      before { allow(user_obj).to receive(:maintenance_details).and_return([]) }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#delete maintenance' do
    subject { user_obj.delete_maintenance(zbxconn_obj, config_hash) }

    context 'when maintenance window is deleted successfully' do
      it 'returns maintenance id' do
        expect(zbxconn_obj).to receive(:query).and_return({})
        subject
      end
    end

    context 'when unable to delete maintenance window' do
      before do
        allow(user_obj).to receive(:maintenance_details).and_return(['maintenanceid'=>'27'])
        allow(zbxconn_obj).to receive(:query).and_raise(ZabbixApi::ApiError.new('Unable to delete maintenance'))
      end

      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end

    context 'when maintenance window doesn\'t exists' do
      before { allow(user_obj).to receive(:maintenance_details).and_return([]) }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end
end
