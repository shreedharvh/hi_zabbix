require 'spec_helper'

describe HiZabbix do
  describe '.create_log' do
    before { subject.create_log.level = Logger::WARN }

    context 'without output location provided' do
      let(:actual) { subject.create_log(nil, Logger::DEBUG) }

      it 'returns a log' do
        expect(actual).to be_a(Logger)
      end

      it 'sets log level to DEBUG' do
        expect(actual.level).to eq(Logger::DEBUG)
      end
    end

    context 'with no parameters' do
      let(:actual) { subject.create_log }

      it 'returns a log' do
        expect(actual).to be_a(Logger)
      end

      it 'sets log level to DEBUG' do
        expect(actual.level).to eq(Logger::WARN)
      end
    end
  end
end
