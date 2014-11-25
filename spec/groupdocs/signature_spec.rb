require 'spec_helper'

describe GroupDocs::Signature do

  it_behaves_like GroupDocs::Api::Entity

  describe '.get!' do
    before(:each) do
      mock_api_server(load_json('signatures_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.get!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::Signature objects' do
      signatures = described_class.get!
      signatures.should be_an(Array)
      signatures.each do |signature|
        signature.should be_a(GroupDocs::Signature)
      end
    end
  end

  describe '.get_for_recipient!' do
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signatures_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.get_for_recipient!(recipient, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      lambda { described_class.get_for_recipient!('Recipient') }.should raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::Signature objects' do
      signatures = described_class.get_for_recipient!(recipient)
      signatures.should be_an(Array)
      signatures.each do |signature|
        signature.should be_a(GroupDocs::Signature)
      end
    end
  end

  it { should have_accessor(:id)                   }
  it { should have_accessor(:userGuid)             }
  it { should have_accessor(:recipientId)          }
  it { should have_accessor(:name)                 }
  it { should have_accessor(:companyName)          }
  it { should have_accessor(:position)             }
  it { should have_accessor(:firstName)            }
  it { should have_accessor(:lastName)             }
  it { should have_accessor(:fullName)             }
  it { should have_accessor(:textInitials)         }
  it { should have_accessor(:signatureImageFileId) }
  it { should have_accessor(:initialsImageFileId)  }
  it { should have_accessor(:signatureImageUrl)    }
  it { should have_accessor(:initialsImageUrl)     }
  it { should have_accessor(:signatureData)        }
  it { should have_accessor(:initialsData)         }
  it { should have_accessor(:createdTimeStamp)     }
  it { should have_accessor(:image_path)           }

  it { should alias_accessor(:user_guid, :userGuid)                           }
  it { should alias_accessor(:recipient_id, :recipientId)                     }
  it { should alias_accessor(:company_name, :companyName)                     }
  it { should alias_accessor(:first_name, :firstName)                         }
  it { should alias_accessor(:last_name, :lastName)                           }
  it { should alias_accessor(:full_name, :fullName)                           }
  it { should alias_accessor(:text_initials, :textInitials)                   }
  it { should alias_accessor(:signature_image_file_id, :signatureImageFileId) }
  it { should alias_accessor(:initials_image_file_id, :initialsImageFileId)   }
  it { should alias_accessor(:signature_image_url, :signatureImageUrl)        }
  it { should alias_accessor(:initials_image_url, :initialsImageUrl)          }
  it { should alias_accessor(:signature_data, :signatureData)                 }
  it { should alias_accessor(:initials_data, :initialsData)                   }
  it { should alias_accessor(:created_time_stamp, :createdTimeStamp)          }

  describe '#create!' do
    before(:each) do
      mock_api_server(load_json('signature_create'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.create!('Signature', :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.create!('Signature')
    end

    it 'updates identifier of signature' do
      lambda do
        subject.create!('Signature')
      end.should change(subject, :id)
    end
  end

  describe '#create_for_recipient!' do
    let(:recipient) { GroupDocs::Signature::Recipient.new }

    before(:each) do
      mock_api_server(load_json('signature_create'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.create_for_recipient!(recipient, 'Signature', :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'raises error if recipient is not GroupDocs::Signature::Recipient object' do
      lambda { subject.create_for_recipient!('Recipient') }.should raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.create_for_recipient!(recipient, 'Signature')
    end

    it 'updates identifier of signature' do
      lambda do
        subject.create_for_recipient!(recipient, 'Signature')
      end.should change(subject, :id)
    end
  end

  describe '#delete!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": {}}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.delete!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end
  end

  describe '#signature_data!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": "Data"}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.signature_data!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns data' do
      subject.signature_data!.should == 'Data'
    end

    it 'updates signature data of signature' do
      lambda do
        subject.signature_data!
      end.should change(subject, :signature_data)
    end
  end

  describe '#initials_data!' do
    before(:each) do
      mock_api_server('{ "status": "Ok", "result": "Data"}')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.initials_data!(:client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns data' do
      subject.initials_data!.should == 'Data'
    end

    it 'updates initials data of signature' do
      lambda do
        subject.initials_data!
      end.should change(subject, :initials_data)
    end
  end
end
