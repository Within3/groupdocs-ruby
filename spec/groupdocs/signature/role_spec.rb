require 'spec_helper'

describe GroupDocs::Signature::Role do

  it_behaves_like GroupDocs::Api::Entity

  describe '.get!' do
    before(:each) do
      mock_api_server(load_json('signature_roles_get'))
    end

    it 'accepts access credentials hash' do
      lambda do
        described_class.get!({}, :client_id => 'client_id', :private_key => 'private_key')
      end.should_not raise_error()
    end

    it 'allows passing options' do
      lambda { described_class.get!(:id => "dsaoij3928ukr03") }.should_not raise_error()
    end

    it 'returns array of GroupDocs::Signature::Role objects' do
      roles = described_class.get!
      roles.should be_an(Array)
      roles.each do |role|
        role.should be_a(GroupDocs::Signature::Role)
      end
    end
  end

  it { should have_accessor(:id)          }
  it { should have_accessor(:name)        }
  it { should have_accessor(:canEdit)     }
  it { should have_accessor(:canSign)     }
  it { should have_accessor(:canAnnotate) }
  it { should have_accessor(:canDelegate) }

  it { should alias_accessor(:can_edit, :canEdit)         }
  it { should alias_accessor(:can_sign, :canSign)         }
  it { should alias_accessor(:can_annotate, :canAnnotate) }
  it { should alias_accessor(:can_delegate, :canDelegate) }

  it { should have_alias(:can_edit?,     :can_edit)     }
  it { should have_alias(:can_sign?,     :can_sign)     }
  it { should have_alias(:can_annotate?, :can_annotate) }
  it { should have_alias(:can_delegate?, :can_delegate) }
end
