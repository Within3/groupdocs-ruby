require 'spec_helper'

describe GroupDocs::User do

  it_behaves_like GroupDocs::Api::Entity

  describe '.get!' do
    before(:each) do
      mock_api_server(load_json('user_profile_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.get!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns GroupDocs::User object' do
      described_class.get!.should be_a(GroupDocs::User)
    end
  end

  it { should respond_to(:id)                  }
  it { should respond_to(:id=)                 }
  it { should respond_to(:guid)                }
  it { should respond_to(:guid=)               }
  it { should respond_to(:nickname)            }
  it { should respond_to(:nickname=)           }
  it { should respond_to(:firstname)           }
  it { should respond_to(:firstname=)          }
  it { should respond_to(:lastname)            }
  it { should respond_to(:lastname=)           }
  it { should respond_to(:primary_email)       }
  it { should respond_to(:primary_email=)      }
  it { should respond_to(:private_key)         }
  it { should respond_to(:private_key=)        }
  it { should respond_to(:password_salt)       }
  it { should respond_to(:password_salt=)      }
  it { should respond_to(:claimed_id)          }
  it { should respond_to(:claimed_id=)         }
  it { should respond_to(:token)               }
  it { should respond_to(:token=)              }
  it { should respond_to(:storage)             }
  it { should respond_to(:storage=)            }
  it { should respond_to(:photo)               }
  it { should respond_to(:photo=)              }
  it { should respond_to(:active)              }
  it { should respond_to(:active=)             }
  it { should respond_to(:news_enabled)        }
  it { should respond_to(:news_enabled=)       }
  it { should respond_to(:signed_up_on)        }
  it { should respond_to(:signed_up_on=)       }
  it { should respond_to(:color)               }
  it { should respond_to(:color=)              }
  it { should respond_to(:customEmailMessage)  }
  it { should respond_to(:customEmailMessage=) }

  it { should have_aliased_accessor(:first_name, :firstname)                    }
  it { should have_aliased_accessor(:last_name, :lastname)                      }
  it { should have_aliased_accessor(:custom_email_message, :customEmailMessage) }

  it { should have_alias(:pkey=, :private_key=)        }
  it { should have_alias(:pswd_salt=, :password_salt=) }
  it { should have_alias(:signedupOn=, :signed_up_on=) }

  describe '#access_rights' do
    it 'returns rights in human-readable format' do
      subject.instance_variable_set(:@access_rights, 15)
      subject.access_rights.should =~ [:export, :view, :proof, :download]
    end
  end

  describe '#access_rights=' do
    it 'converts rights in machine-readable format if array is passed' do
      subject.access_rights = %w(export view proof download)
      subject.instance_variable_get(:@access_rights).should == 15
    end

    it 'does nothing if not array is passed' do
      subject.access_rights = 15
      subject.instance_variable_get(:@access_rights).should == 15
    end
  end

  describe '#signed_up_on' do
    it 'returns converted to Time object Unix timestamp' do
      subject.signed_up_on = 1330450135000
      subject.signed_up_on.should == Time.at(1330450135)
    end
  end

  describe '#update!' do
    before(:each) do
      mock_api_server('{ "result": { "user_guid": "s8dfts8" }, "status": "Ok" }')
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.update!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'uses hashed version of self as request body' do
      subject.should_receive(:to_hash)
      subject.update!
    end
  end

  describe '#users!' do
    before(:each) do
      mock_api_server(load_json('user_users_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.users!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'returns array of GroupDocs::User objects' do
      users = subject.users!
      users.should be_an(Array)
      users.each do |user|
        user.should be_a(GroupDocs::User)
      end
    end
  end
end
