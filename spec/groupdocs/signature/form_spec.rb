require 'spec_helper'

describe GroupDocs::Signature::Form do

  it_behaves_like GroupDocs::Api::Entity
  include_examples GroupDocs::Signature::EntityMethods
  include_examples GroupDocs::Signature::DocumentMethods
  include_examples GroupDocs::Signature::FieldMethods
  include_examples GroupDocs::Signature::ResourceMethods

  describe '.all!' do
    before(:each) do
      mock_api_server(load_json('forms_all'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.all!({}, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end

    it 'allows passing options' do
      lambda { described_class.all!(:page => 1, :count => 3) }.should_not raise_error()
    end

    it 'returns array of GroupDocs::Signature::Form objects' do
      forms = described_class.all!
      forms.should be_an(Array)
      forms.each do |form|
        form.should be_a(GroupDocs::Signature::Form)
      end
    end
  end

  it { should have_accessor(:id)                         }
  it { should have_accessor(:name)                       }
  it { should have_accessor(:ownerGuid)                  }
  it { should have_accessor(:templateGuid)               }
  it { should have_accessor(:createdTimeStamp)           }
  it { should have_accessor(:statusDateTime)             }
  it { should have_accessor(:documentsCount)             }
  it { should have_accessor(:documentsPages)             }
  it { should have_accessor(:participantsCount)          }
  it { should have_accessor(:fieldsInFinalFileName)      }
  it { should have_accessor(:canParticipantDownloadForm) }
  it { should have_accessor(:status)                     }
  it { should have_accessor(:waterMarkText)              }
  it { should have_accessor(:waterMarkImage)             }

  it { should alias_accessor(:owner_guid, :ownerGuid)                                     }
  it { should alias_accessor(:template_guid, :templateGuid)                               }
  it { should alias_accessor(:created_time_stamp, :createdTimeStamp)                      }
  it { should alias_accessor(:status_date_time, :statusDateTime)                          }
  it { should alias_accessor(:documents_count, :documentsCount)                           }
  it { should alias_accessor(:documents_pages, :documentsPages)                           }
  it { should alias_accessor(:participants_count, :participantsCount)                     }
  it { should alias_accessor(:can_participant_download_form, :canParticipantDownloadForm) }
  it { should alias_accessor(:water_mark_text, :waterMarkText)                            }
  it { should alias_accessor(:water_mark_image, :waterMarkImage)                          }

  describe '#status' do
    it 'converts status to human-readable format' do
      subject.status = 1
      subject.status.should == :in_progress
    end
  end

  describe '#fields_in_final_file_name=' do
    it 'converts field names in machine-readable format if array is passed' do
      subject.fields_in_final_file_name = %w(on off)
      subject.instance_variable_get(:@fieldsInFinalFileName).should == 'on,off'
    end

    it 'saves field names as is if not an array is passed' do
      subject.fields_in_final_file_name = 'on,off'
      subject.instance_variable_get(:@fieldsInFinalFileName).should == 'on,off'
    end
  end

  #describe '#fields_in_final_file_name' do
  #  it 'returns field names in human-readable format' do
  #    subject.fields_in_final_file_name = %w(on off)
  #    subject.fields_in_final_file_name.should == %w(on off)
  #  end
  #end

  describe '#create!' do
    before(:each) do
      mock_api_server(load_json('form_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.create!({}, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end

    it 'accepts options hash' do
      lambda do
        subject.create!(:assembly_id => 'aodfh43yr9834hf943h')
      end.should_not raise_error()
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.create!
    end

    it 'updates identifier of entity' do
      lambda do
        subject.create!
      end.should change(subject, :id)
    end
  end

  describe '#documents!' do
    before(:each) do
      mock_api_server(load_json('template_get_documents'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.documents!({}, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end

    it 'can be public' do
      lambda { subject.documents!(:public => true) }.should_not raise_error()
    end

    it 'returns array of GroupDocs::Document objects' do
      documents = subject.documents!
      documents.should be_an(Array)
      documents.each do |document|
        document.should be_a(GroupDocs::Document)
      end
    end
  end

  describe '#publish!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.publish!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end
  end

  describe '#complete!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.complete!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end
  end

  describe '#archive!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.archive!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end
  end

  describe '#update_from_template!' do
    let(:template) { GroupDocs::Signature::Template.new }
    let(:form) { GroupDocs::Signature::Form.new }

    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'raises error if template is not GroupDocs::Signature::Template object' do
      lambda { subject.update_from_template!('Template') }.should raise_error(ArgumentError)
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.update_from_template!(template, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end
  end
  describe '#get_fields!' do
    before(:each) do
      mock_api_server(load_json('signature_fields_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.get_fields!({}, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end
  end
end
