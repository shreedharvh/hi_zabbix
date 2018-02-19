require 'spec_helper'

describe HiZabbix::Commands do
  let(:actual) { HiZabbix::Commands.start(ARGV) }

  context 'when command not found' do
    it 'responds with error command cannot be found' do
      ARGV.replace %w(help unknown)
      content = capture(:stderr) { actual }
      expect(content.strip).to match(/Could not find command "unknown"/m)
    end
  end

  context "when command option 'template_upload' not specified" do
    it "responds with ERROR: command option 'template_upload' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr) { actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'create_host' not specified" do
    it "responds with ERROR: command option 'create_host' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr) { actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'create_hostgroup' not specified" do
    it "responds with ERROR: command option 'create_hostgroup' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr) { actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'create_user' not specified" do
    it "responds with ERROR: command option 'create_user' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr) { actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'create_maintenance' not specified" do
    it "responds with ERROR: command option 'create_maintenance' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr){ actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'update_maintenance' not specified" do
    it "responds with ERROR: command option 'update_maintenance' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr){ actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context "when command option 'delete_maintenance' not specified" do
    it "responds with ERROR: command option 'delete_maintenance' not specified" do
      ARGV.replace %w(-c)
      content = capture(:stderr){ actual }
      expect(content.strip).to match(/Could not find command/m)
    end
  end

  context 'when option configfile has default type :string' do
    it { expect(parse(:configfile, :default).type).to eq(:string) }
  end

  context 'when option tempatefile has no default value and equals to :required' do
    it { expect(parse(:tempatefile, :required).default).to be nil }
  end

  context 'when option tempatefile has default type :string' do
    it { expect(parse(:tempatefile, :default).type).to eq(:string) }
  end

  context "when command option 'template_upload' specified without parameters" do
    it "responds with ERROR: No value provided for required options" do
      ARGV.replace %w(template_upload)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'create_host' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(create_host)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'create_hostgroup' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(create_hostgroup)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'create_user' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(create_user)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'create_maintenance' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(create_maintenance)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'update_maintenance' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(update_maintenance)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'delete_maintenance' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(delete_maintenance)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when command option 'health_check' is specified without parameters" do
    it 'responds with ERROR: No value provided for required options' do
      ARGV.replace %w(health_check)
      content = capture(:stderr) { actual }
      expect(content.strip).to be_a_kind_of(String)
    end
  end

  context "when 'health_check' is performed successfully" do
    before do
      ARGV = [ 'health_check', '-c', File.expand_path('../files/valid_test_config.yml',File.dirname(__FILE__)), '-h', 'whoami', '-n', '127.0.0.1']
      allow(STDIN).to receive(:gets).and_return('ab12345')
      allow(STDIN).to receive(:noecho).and_return('password')
      allow(STDIN).to receive(:gets).and_return('jira-1234')
      allow_any_instance_of(JiraComment).to receive(:comment).and_return(true)
    end
    it 'logs a success message' do
      expect_any_instance_of(Logger).to receive(:info).with('Successfully performed the health check operation')
      expect_any_instance_of(Logger).to receive(:info).with('Posted the Health Check version on the JIRA')
      expect(actual).to be true
    end
  end

  context "when failed to run 'health_check' operation" do
    before do 
      ARGV = [ 'health_check', '-c', File.expand_path('../files/valid_test_config.yml',File.dirname(__FILE__)), '-h', 'whoami', '-n', '123.456.789']
      allow(STDIN).to receive(:gets).and_return('ab12345')
      allow(STDIN).to receive(:noecho).and_return('password')
      allow(STDIN).to receive(:gets).and_return('jira-1234')
      allow_any_instance_of(Array).to receive_message_chain(:flatten, :empty?).and_return(true)
    end
    it 'logs an ERROR message' do
      expect_any_instance_of(Logger).to receive(:info).with(RuntimeError)
      actual
    end
  end
end
