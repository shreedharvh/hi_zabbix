require 'spec_helper'

describe 'HiZabbix::User' do
  let (:user_obj) { HiZabbix::User.new(YAML.load_file('spec/files/valid_test_config.yml')) }
  let (:zbxconn_obj) { user_obj.zabbix_connection('user','pwd') }
  let (:zbxapi_obj) { instance_double(ZabbixApi) }
  let (:config_hash) { {"conf_file_path"=>"config.yml", "name"=>"someone", "alias"=>"someonesalias", "user_group"=>"somegroup"} }

  describe '#create_user' do
    subject { user_obj.create_user(zbxconn_obj, config_hash) }

    before do
      allow(user_obj).to receive(:zabbix_connection).and_return(zbxapi_obj)
      allow(user_obj).to receive(:user_details).and_return([])
    end

    context 'when user is created successfully' do
      before do 
        allow(user_obj).to receive(:groupid).and_return(Fixnum)
        allow(STDIN).to receive(:gets).and_return(1)
        allow(STDIN).to receive(:noecho).and_return('password')
      end

      it 'returns userid' do
        expect(zbxconn_obj).to receive_message_chain(:users, :create).and_return(Fixnum)
        subject
      end
    end

    context 'when user already exist' do
      before do
        allow(user_obj).to receive(:groupid).and_return(Fixnum)
        allow(user_obj).to receive(:user_details).and_return(['alias'=>'SH12345'])
        allow(STDIN).to receive(:gets).and_return(1)
      end

      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when user group doesnt exist' do
      before do 
        allow(user_obj).to receive(:groupid).and_return(nil)
        allow(STDIN).to receive(:gets).and_return(1)
      end
      it 'returns nil' do
        expect(subject).to be nil
      end
    end

    context 'when unable to create user' do
      let(:zbxuser) { ZabbixApi::Users }
      before do 
        allow(user_obj).to receive(:groupid).and_return(Fixnum)
        allow(zbxconn_obj).to receive_message_chain(:users, :create).and_raise(ZabbixApi::ApiError.new('Unable to create user'))
        allow(STDIN).to receive(:gets).and_return(1)
        allow(STDIN).to receive(:noecho).and_return('password')
      end

      it 'raises API error' do
        expect{subject}.to raise_error(ZabbixApi::ApiError)
      end
    end
  end
end
