require 'spec_helper'

describe GroupDocs::Document do

  it_behaves_like GroupDocs::Api::Entity
  include_examples GroupDocs::Api::Sugar::Lookup

  subject do
    file = GroupDocs::Storage::File.new
    described_class.new(file: file)
  end

  describe '#initialize' do
    it 'raises error if file is not specified' do
      -> { described_class.new }.should raise_error(ArgumentError)
    end

    it 'raises error if file is not an instance of GroupDocs::Storage::File' do
      -> { described_class.new(file: '') }.should raise_error(ArgumentError)
    end
  end

  context 'attributes' do
    it { should respond_to(:file)  }
    it { should respond_to(:file=) }
  end

  context 'class methods' do
    describe '#views!' do
      before(:each) do
        mock_api_server(load_json('document_views'))
      end

      it 'adds page index option by default' do
        GroupDocs::Api::Request.any_instance.should_receive(:add_params).with({ page_index: 0 })
        described_class.views!
      end

      it 'returns an array of GroupDocs::Document::View objects' do
        views = described_class.views!
        views.should be_an(Array)
        views.each do |view|
          view.should be_a(GroupDocs::Document::View)
        end
      end
    end

    describe '#all!' do
      it 'calls GroupDocs::Storage::File.all! and converts each file to document' do
        file1 = GroupDocs::Storage::File.new
        file2 = GroupDocs::Storage::File.new
        GroupDocs::Storage::File.should_receive(:all!).and_return([file1, file2])
        file1.should_receive(:to_document).and_return(described_class.new(file: file1))
        file2.should_receive(:to_document).and_return(described_class.new(file: file2))
        described_class.all!
      end
    end
  end

  context 'instance methods' do
    describe '#access_mode!' do
      it 'returns access mode in human readable presentation' do
        mock_api_server(load_json('document_access_info_get'))
        subject.should_receive(:parse_access_mode).with(0).and_return(:private)
        subject.access_mode!.should == :private
      end
    end

    describe '#access_mode=' do
      it 'sets corresponding access mode' do
        mock_api_server('{"status": "Ok", "result": {"access": 0 }}')
        subject.should_receive(:parse_access_mode).with(:private).and_return(0)
        subject.access_mode = :private
      end
    end

    describe '#formats!' do
      it 'returns an array of symbols' do
        mock_api_server(load_json('document_formats'))
        formats = subject.formats!
        formats.should be_an(Array)
        formats.each do |format|
          format.should be_a(Symbol)
        end
      end
    end

    describe '#metadata!' do
      before(:each) do
        mock_api_server(load_json('document_metadata'))
      end

      it 'returns GroupDocs::Document::MetaData' do
        subject.metadata!.should be_a(GroupDocs::Document::MetaData)
      end

      it 'sets last view as GroupDocs::Document::View if document was viewed at least once' do
        subject.metadata!.last_view.should be_a(GroupDocs::Document::View)
      end

      it 'uses self document in last view object' do
        subject.metadata!.last_view.document.should == subject
      end

      it 'does not set last view if document has never been viewed' do
        mock_api_server('{"status": "Ok", "result": {"last_view": null }}')
        subject.metadata!.last_view.should be_nil
      end
    end

    describe '#fields!' do
      it 'returns array of GroupDocs::Document::Field objects' do
        mock_api_server(load_json('document_fields'))
        fields = subject.fields!
        fields.should be_an(Array)
        fields.each do |field|
          field.should be_a(GroupDocs::Document::Field)
        end
      end
    end

    describe '#thumbnail!' do
      it 'accepts options hash' do
        mock_api_server(load_json('document_thumbnail'))
        lambda do
          subject.thumbnail!(page_number: 1, page_count: 2, use_pdf: true)
        end.should_not raise_error
      end
    end

    describe '#sharers!' do
      it 'returns an array of GroupDocs::User objects' do
        mock_api_server(load_json('document_access_info_get'))
        users = subject.sharers!
        users.should be_an(Array)
        users.each do |user|
          user.should be_a(GroupDocs::User)
        end
      end
    end

    describe '#sharers=' do
      it 'accepts emails array' do
        mock_api_server(load_json('document_sharers_set'))
        lambda do
          subject.sharers = %w(test1@email.com test2@email.com)
        end.should_not raise_error
      end

      it 'clears sharers if empty array is passed' do
        subject.should_receive(:sharers_clear!)
        subject.sharers = []
      end

      it 'clears sharers if nil is passed' do
        subject.should_receive(:sharers_clear!)
        subject.sharers = nil
      end
    end

    describe '#sharers_clear!' do
      it 'clears sharers list and returns nil' do
        mock_api_server(load_json('document_sharers_remove'))
        subject.sharers_clear!.should be_nil
      end
    end

    describe '#convert!' do
      before(:each) do
        mock_api_server(load_json('document_convert'))
      end

      it 'accepts options hash' do
        lambda do
          subject.convert!(:pdf, email_results: true)
        end.should_not raise_error
      end

      it 'returns GroupDocs::Job object' do
        subject.convert!(:pdf).should be_a(GroupDocs::Job)
      end
    end

    describe '#inspect' do
      it 'returns object in nice presentation' do
        file_opts = { id: 1, guid: 'sdyf8a8f', name: 'Test.pdf', url: 'https://groupdocs.com' }
        options = { file: GroupDocs::Storage::File.new(file_opts) }
        subject = described_class.new(options)
        subject.inspect.should ==
          %(<##{described_class} @file=#{options[:file].inspect}">)
      end
    end

    describe '#method_missing' do
      it 'passes unknown methods to file object' do
        -> { subject.name }.should_not raise_error(NoMethodError)
      end

      it 'raises NoMethodError if neither self nor file responds to method' do
        -> { subject.unknown_method }.should raise_error(NoMethodError)
      end
    end

    describe '#respond_to?' do
      it 'returns true if self responds to method' do
        subject.respond_to?(:metadata!).should be_true
      end

      it 'returns true if file object responds to method' do
        subject.respond_to?(:name).should be_true
      end

      it 'returns false if neither self nor file responds to method' do
        subject.respond_to?(:unknown).should be_false
      end
    end

    describe '#parse_access_mode' do
      it 'raise error if mode is unknown' do
        -> { subject.send(:parse_access_mode, 3)        }.should raise_error(ArgumentError)
        -> { subject.send(:parse_access_mode, :unknown) }.should raise_error(ArgumentError)
      end

      it 'returns :private if passed mode is 0' do
        subject.send(:parse_access_mode, 0).should == :private
      end

      it 'returns :restricted if passed mode is 1' do
        subject.send(:parse_access_mode, 1).should == :restricted
      end

      it 'returns :public if passed mode is 2' do
        subject.send(:parse_access_mode, 2).should == :public
      end

      it 'returns 0 if passed mode is :private' do
        subject.send(:parse_access_mode, :private).should == 0
      end

      it 'returns 1 if passed mode is :restricted' do
        subject.send(:parse_access_mode, :restricted).should == 1
      end

      it 'returns 2 if passed mode is :public' do
        subject.send(:parse_access_mode, :public).should == 2
      end
    end
  end
end
