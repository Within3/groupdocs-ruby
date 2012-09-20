require 'spec_helper'

describe GroupDocs::Signature::Template do

  it_behaves_like GroupDocs::Api::Entity
  include_examples GroupDocs::Signature::DocumentMethods
  include_examples GroupDocs::Signature::RecipientMethods
  include_examples GroupDocs::Signature::TemplateFields

  describe '.all!' do
    before(:each) do
      mock_api_server(load_json('templates_all'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.all!({}, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'allows passing options' do
      -> { described_class.all!(page: 1, count: 3) }.should_not raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::Signature::Template objects' do
      templates = described_class.all!
      templates.should be_an(Array)
      templates.each do |template|
        template.should be_a(GroupDocs::Signature::Template)
      end
    end
  end

  describe '.get!' do
    before(:each) do
      mock_api_server(load_json('template_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.get!("j5498fre9fje9f", client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns GroupDocs::Signature::Template objects' do
      described_class.get!("j5498fre9fje9f").should be_a(GroupDocs::Signature::Template)
    end
  end

  it { should respond_to(:templateExpireTime)  }
  it { should respond_to(:templateExpireTime=) }

  it { should have_alias(:template_expire_time, :templateExpireTime)   }
  it { should have_alias(:template_expire_time=, :templateExpireTime=) }

  describe '#create!' do
    before(:each) do
      mock_api_server(load_json('template_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.create!({}, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'accepts options hash' do
      lambda do
        subject.create!(templateId: 'aodfh43yr9834hf943h')
      end.should_not raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.create!
    end

    it 'updates identifier of template' do
      lambda do
        subject.create!
      end.should change(subject, :id)
    end
  end

  describe '#modify!' do
    before(:each) do
      mock_api_server(load_json('template_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.modify!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.modify!
    end
  end

  describe '#rename!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": { "template": null }}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.rename!('Name', client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'updates name of template' do
      lambda do
        subject.rename!('Name')
      end.should change(subject, :name)
    end
  end

  describe '#delete!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": { "template": null }}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end

  describe '#add_recipient!' do
    let(:recipient) do
      GroupDocs::Signature::Recipient.new
    end

    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.add_recipient!(recipient, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      -> { subject.add_recipient!('Recipient') }.should raise_error(ArgumentError)
    end
  end

  describe '#modify_recipient!' do
    let(:recipient) do
      GroupDocs::Signature::Recipient.new
    end

    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.modify_recipient!(recipient, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      -> { subject.modify_recipient!('Recipient') }.should raise_error(ArgumentError)
    end
  end

  describe '#fields!' do
    let(:document)  { GroupDocs::Document.new(file: GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_fields_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.fields!(document, recipient, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if document is not GroupDocs::Document object' do
      -> { subject.fields!('Document', recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      -> { subject.fields!(document, 'Recipient') }.should raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::Signature::Field objects' do
      fields = subject.fields!(document, recipient)
      fields.should be_an(Array)
      fields.each do |field|
        field.should be_a(GroupDocs::Signature::Field)
      end
    end
  end

  describe '#add_field!' do
    let(:field)     { GroupDocs::Signature::Field.new(location: { location_x: 0.1, page: 1 }) }
    let(:document)  { GroupDocs::Document.new(file: GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_field_add'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.add_field!(field, document, recipient, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      -> { subject.add_field!('Field', document, recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if document is not GroupDocs::Document object' do
      -> { subject.add_field!(field, 'Document', recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      -> { subject.add_field!(field, document, 'Recipient') }.should raise_error(ArgumentError)
    end

    it 'raises error if field does not specify location' do
      field = GroupDocs::Signature::Field.new
      -> { subject.add_field!(field, document, recipient) }.should raise_error(ArgumentError)
    end

    it 'uses field, field location and forcedNewField flag as payload' do
      payload = {}
      location = {}
      field.should_receive(:to_hash).and_return(payload)
      field.location.should_receive(:to_hash).and_return(location)
      payload.should_receive(:merge!).with(location).and_return(payload)
      payload.should_receive(:merge!).with(forceNewField: true).and_return({})
      subject.add_field!(field, document, recipient)
    end
  end

  describe '#delete_field!' do
    let(:field) do
      GroupDocs::Signature::Field.new
    end

    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      -> { subject.delete_field!('Field') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete_field!(field, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end

  describe '#modify_field_location!' do
    let(:field)     { GroupDocs::Signature::Field.new }
    let(:document)  { GroupDocs::Document.new(file: GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }
    let(:location)  { GroupDocs::Signature::Field::Location.new }

    before(:each) do
      mock_api_server(load_json('signature_field_add'))
    end

    it 'raises error if location is not GroupDocs::Signature::Field::Location object' do
      -> { subject.modify_field_location!('Location', field, document, recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      -> { subject.modify_field_location!(location, 'Field', document, recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if document is not GroupDocs::Document object' do
      -> { subject.modify_field_location!(location, field, 'Document', recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      -> { subject.modify_field_location!(location, field, document, 'Recipient') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.modify_field_location!(location, field, document, recipient, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end

  describe '#delete_field_location!' do
    let(:field)    { GroupDocs::Signature::Field.new }
    let(:location) { GroupDocs::Signature::Field::Location.new }

    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'raises error if location is not GroupDocs::Signature::Field::Location object' do
      -> { subject.delete_field_location!('Location', field) }.should raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      -> { subject.delete_field_location!(location, 'Field') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete_field_location!(location, field, client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end
end
