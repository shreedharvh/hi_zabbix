require 'spec_helper'

describe JiraComment do 
  let(:actual) { JiraComment.new('AB123', '*****', File.expand_path('test_files/config.yml',File.dirname(__FILE__)))}

  describe '#initialize' do

    context 'when config file does not exist' do
      before { allow(File).to receive(:exist?).and_return(false) }

      it 'raises RuntimeError' do
        expect{actual}.to raise_error(RuntimeError)
      end
    end

    context 'when config file is empty' do
      before { allow(File).to receive(:zero?).and_return(true) }

      it 'raises RuntimeError' do
        expect{actual}.to raise_error(RuntimeError)
      end
    end

    context 'when config file is read' do 
      it 'returns the actual object' do
        expect(actual).to be_kind_of(JiraComment)
      end
    end
  end

  describe '#load_config' do
    let (:config) { {'jira_api_root'=>{'jira3'=>'https://jira3.cerner.com'}} }
    subject { actual.load_config(File.expand_path('test_files/config.yml',File.dirname(__FILE__)))}

    before { allow(YAML).to receive(:load).and_return(config) }

    context 'when api root is nil' do
      let (:config) { {'jira_api_root'=>{'jira3'=>nil}} }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when api_root url format is incorrect' do
      let (:config) { {'jira_api_root'=>{'jira3'=>'bad_url'}} }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when none of the config file parameters are nil' do
      it 'returns hash' do
        expect(subject).to eq(config)
      end
    end
  end

  describe '#valid_url_format?' do
    let(:url) { 'https://jira3.cerner.com' }
    subject { actual.valid_url_format?(url) }

    context 'when an invalid url is given' do
      let(:url) { 'badurl' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when an empty url is given' do
      let(:url) { '' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when a valid url is given' do
      it 'returns a true value 0' do
        expect(subject).to eq(0)
      end
    end
  end

  describe '#create_jira_object' do
    let(:instance) { 'https://jira3.cerner.com' }

    it 'returns a JIRA client object' do
      expect(actual.create_jira_object(instance)).to be_kind_of(JIRA::Client)
    end
  end

  describe '#get_client' do
    let(:queue) { 'ETSDEV' }
    let(:client) { JIRA::Client }

    before(:each) { allow(actual).to receive(:create_jira_object).and_return(client) }

    subject { actual.get_client(queue) }

    context 'when the queue given is invalid' do
      let(:queue) { 'ETSDEVCSO' }

      before { allow(client).to receive_message_chain(:Project, :all).and_return([]) }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'with unauthorized access' do
      before { allow(client).to receive_message_chain(:Project, :all).and_raise(JIRA::HTTPError.new(Net::HTTPUnauthorized.new('get', '401', 'invalid credntials'))) }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when wrong url or no internet' do
      before { allow(client).to receive_message_chain(:Project, :all).and_raise(SocketError) }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when the given queue is valid' do
      let(:project) {['ETSDEV']}
      let(:project_obj) {double('JIRA::Resource::Project')}
      before do
        allow(client).to receive(:Project).and_return(project_obj)
        allow(project_obj).to receive(:all).and_return(project)
        allow(project).to receive(:any?).and_return(true)
      end

      it 'returns a JIRA client object' do
        expect(subject).to eq(JIRA::Client)
      end
    end
  end

  describe '#jira_id' do
    let(:jira) { 'ETSDEV-3965' }
    let(:client) { JIRA::Client }

    subject { actual.jira_id(jira, client) }

    context 'when the given jira number is valid' do
      before { allow(client).to receive_message_chain(:Issue, :find).and_return(JIRA::Resource::Issue) }
      
      it 'returns a JIRA::Resource::Issue object' do
        expect(subject).to eq(JIRA::Resource::Issue)
      end
    end

    context 'when the given jira number doesn\'t exist' do
      before { allow(client).to receive_message_chain(:Issue, :find).and_raise(JIRA::HTTPError) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#comment' do
    let(:jira) { 'ETSDEV-3965' }
    let(:input) { 'test case string input jira_comment' }
    let(:format) { 'string' }
    let(:issue) { double(JIRA::Resource::Issue) }

    before(:each) do 
      allow(actual).to receive(:get_client).and_return(JIRA::Client)
      allow(actual).to receive(:jira_id).and_return(issue)
    end

    subject { actual.comment(jira, input, format) }

    context 'when the given jira queue is invalid' do
      before { allow(actual).to receive(:get_client).and_raise(RuntimeError) }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when the given jira number doesn\'t exist' do
      before { allow(actual).to receive(:jira_id).and_return(nil) }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end

    context 'when invalid table input is given' do
      let(:input) { { 'header' => 'test case table input jira_comment', 'footer' => 'done!', 'title' => 'Table:', 'rows' => [['2017-01-12', true]] } }
      let(:format) { 'table' }

      before { allow(JiraCommentFormat).to receive(:table_format).with(input).and_raise(RuntimeError,'Please provide columns/rows values in the input') }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError,'Please provide columns/rows values in the input')
      end
    end

    context 'when invalid list input is given' do
      let(:input) { { 'title' => 'Test list' } }
      let(:format) { 'list' }

      before { allow(JiraCommentFormat).to receive(:list_format).with(input).and_raise(RuntimeError,'Please provide list values in the input') }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError,'Please provide list values in the input')
      end
    end

    context 'when invalid miscellaneous input is given' do
      let(:input) { [{'format' => 'list', 'value' => {'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] }},
                     {'value' => {'columns' => ['date'], 'rows' => [['2012-12-12'],['2013-12-12']]}}] }
      let(:format) { 'miscellaneous' }

      before { allow(JiraCommentFormat).to receive(:miscellaneous_format).with(input).and_raise(RuntimeError,'Please provide format and value in the input') }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError,'Please provide format and value in the input')
      end
    end

    context 'when valid input is given' do
      before { allow(issue).to receive_message_chain(:comments, :build, :save).and_return(true) }
      it 'returns true' do
        expect(subject).to be true
      end
    end
  end
end
