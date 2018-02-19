require 'spec_helper'

describe JiraCommentFormat do
  
  describe '.table_format' do
    let(:input) { { 'header' => 'test', 'footer' => 'done!', 'title' => 'Table:', 'columns' => ['date','status'], 'rows' => [['2017-01-12', true]] } }
    subject { JiraCommentFormat::table_format(input) }

    context 'when input is invalid' do
      let(:input) { { 'header' => 'test', 'footer' => 'done!', 'title' => 'Table:', 'rows' => [['2017-01-12', true]] } }

      it 'raises RuntimeError' do 
        expect{subject}.to raise_error(RuntimeError,'Please provide columns/rows values in the input')
      end
    end

    context 'when input is valid' do
      it 'returns table formatted string' do
        expect(subject).to eql("\n\ntest\n\n\n\nTable:\n\n||date||status\n|2017-01-12|(/)\n\ndone!\n\n")
      end
    end
  end

  describe '.list_format' do
    let(:input) { { 'title' => 'Test list', 'list' => [ 'A', 'B', 'C'] } }
    subject { JiraCommentFormat::list_format(input) }

    context 'when input is invalid' do
      let(:input) { {'title' => 'Test list', 'type' => 'numbered' } }

      it 'raises RuntimeError' do
        expect{subject}.to raise_error(RuntimeError,'Please provide list values in the input')
      end
    end

    context 'when input is valid' do
      it 'returns list formatted string' do
        expect(subject).to eql("\n\nTest list\n\n* A\n* B\n* C\n")
      end
    end 
  end

  describe '.miscellaneous_format' do
    let(:input) { [{'format' => 'list', 'value' => {'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] }},
                   {'format' => 'table', 'value' => {'columns' => ['date'], 'rows' => [['2012-12-12'],['2013-12-12']]}}] }
    subject { JiraCommentFormat::miscellaneous_format(input) }

    context 'when input format is invalid' do
      let(:input) { [{'format' => 'abc', 'value' => {'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] }}] }

      it 'raises RuntimeError' do 
        expect{subject}.to raise_error(RuntimeError, /Invalid comment format : '[a-zA-Z0-9]+' specified/)
      end
    end

    context 'when input is invalid' do
      let(:input) { [{'value' => {'list' => [ 'A', 'B', ['B.1', 'B.2'], 'C'] }}] }

      it 'raises RuntimeError' do 
        expect{subject}.to raise_error(RuntimeError, 'Please provide format and value in the input')
      end
    end

    context 'when input is valid' do
      it 'returns table formatted string' do
        expect(subject).to eql("\n\n* A\n* B\n** B.1\n** B.2\n* C\n\n\n\n\n||date\n|2012-12-12\n|2013-12-12\n\n")
      end
    end
  end
end
