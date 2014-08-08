shared_examples_for GroupDocs::Signature::FieldMethods do
  let(:args) do
    case described_class.name
    when 'GroupDocs::Signature::Form'
      [document]
    when 'GroupDocs::Signature::Template', 'GroupDocs::Signature::Envelope'
      [document, recipient]
    end
  end

  describe '#fields!' do
    let(:document)  { GroupDocs::Document.new(:file => GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_fields_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.fields!(*args, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::Signature::Field objects' do
      fields = subject.fields!(*args)
      fields.should be_an(Array)
      fields.each do |field|
        field.should be_a(GroupDocs::Signature::Field)
      end
    end
  end

  describe '#add_field!' do
    let(:field)     { GroupDocs::Signature::Field.new(:location => { :location_x => 0.1, :page => 1 }) }
    let(:document)  { GroupDocs::Document.new(:file => GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_field_add'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.add_field!(field, *args, { :force_new_field => false }, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      lambda { subject.add_field!('Field', *args) }.should raise_error(ArgumentError)
    end

    it 'raises error if field does not specify location' do
      field = GroupDocs::Signature::Field.new
      lambda { subject.add_field!(field, *args) }.should raise_error(ArgumentError)
    end

    it 'uses field and field locationas payload' do
      hash_one = {}
      payload = {}
      location = {}
      field.should_receive(:to_hash).and_return(payload)
      field.location.should_receive(:to_hash).and_return(location)
      payload.should_receive(:merge!).with(location).and_return(payload)
      payload.should_receive(:merge!).with(:forceNewField => true).and_return({})
      subject.add_field!(field, *args)
    end

    it 'allows overriding force new field flag' do
      hash_one = {}
      payload = {}
      location = {}
      field.should_receive(:to_hash).and_return(payload)
      field.location.should_receive(:to_hash).and_return(location)
      payload.should_receive(:merge!).with(location).and_return(payload)
      payload.should_receive(:merge!).with(:forceNewField => false).and_return({})
      subject.add_field!(field, *args, :force_new_field => false)
    end
  end

  describe '#modify_field!' do
    let(:field)    { GroupDocs::Signature::Field.new }
    let(:document) { GroupDocs::Document.new(:file => GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_field_add'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.modify_field!(field, document, recipient, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      lambda { subject.modify_field!('Field', document, recipient) }.should raise_error(ArgumentError)
    end

    it 'raises error if document is not GroupDocs::Document object' do
      lambda { subject.modify_field!(field, 'Document', recipient) }.should raise_error(ArgumentError)
    end

    it 'uses field and first field location as payload' do
      payload   = {}
      location  = {}
      locations = [location]
      field.should_receive(:to_hash).and_return(payload)
      payload.should_receive(:delete).with(:locations).and_return(payload)
      field.should_receive(:locations).and_return(locations)
      locations.should_receive(:first).and_return(location)
      payload.should_receive(:merge!).with(location).and_return(payload)
      subject.modify_field!(field, document, recipient)
    end
  end

  describe '#assign_field!' do
    case described_class.name
    when 'GroupDocs::Signature::Form'
      it 'does not have #assign_field! method' do
        subject.methods.should_not include(:assign_field!)
      end
    when 'GroupDocs::Signature::Template', 'GroupDocs::Signature::Envelope'
      let(:field)       { GroupDocs::Signature::Field.new }
      let(:document)    { GroupDocs::Document.new(:file => GroupDocs::Storage::File.new) }
      let(:assign_from) { GroupDocs::Signature::Recipient.new }
      let(:assign_to)   { GroupDocs::Signature::Recipient.new }

      before(:each) do
        mock_api_server(load_json('signature_field_add'))
      end

      it 'accepts access credentials hash' do
        lambda do
          subject.assign_field!(field, document, assign_from, assign_to, :client_id => 'client_id', :private_key => 'private_key')
        end.should_not raise_error(ArgumentError)
      end

      it 'raises error if field is not GroupDocs::Signature::Field object' do
        lambda { subject.assign_field!('Field', document, assign_from, assign_to) }.should raise_error(ArgumentError)
      end

      it 'raises error if document is not GroupDocs::Document object' do
        lambda { subject.assign_field!(field, 'Document', assign_from, assign_to) }.should raise_error(ArgumentError)
      end

      it 'raises error if assign from is not GroupDocs::Signature::Recipient object' do
        lambda { subject.assign_field!(field, document, 'Assign', assign_to) }.should raise_error(ArgumentError)
      end

      it 'raises error if assign to is not GroupDocs::Signature::Recipient object' do
        lambda { subject.assign_field!(field, document, assign_from, 'Assign') }.should raise_error(ArgumentError)
      end
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
      lambda { subject.delete_field!('Field') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete_field!(field, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end

  describe '#modify_field_location!' do
    let(:field)     { GroupDocs::Signature::Field.new }
    let(:document)  { GroupDocs::Document.new(:file => GroupDocs::Storage::File.new) }
    let(:recipient) { GroupDocs::Signature::Recipient.new }
    let(:location)  { GroupDocs::Signature::Field::Location.new }

    before(:each) do
      mock_api_server(load_json('signature_field_add'))
    end

    it 'raises error if location is not GroupDocs::Signature::Field::Location object' do
      lambda { subject.modify_field_location!('Location', field, *args) }.should raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      lambda { subject.modify_field_location!(location, 'Field', *args) }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.modify_field_location!(location, field, *args, :client_id => 'client_id', :private_key => 'private_key')
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
      lambda { subject.delete_field_location!('Location', field) }.should raise_error(ArgumentError)
    end

    it 'raises error if field is not GroupDocs::Signature::Field object' do
      lambda { subject.delete_field_location!(location, 'Field') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete_field_location!(location, field, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end
end
