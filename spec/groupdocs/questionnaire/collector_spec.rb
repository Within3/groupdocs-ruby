require 'spec_helper'

describe GroupDocs::Questionnaire::Collector do

  it_behaves_like GroupDocs::Api::Entity
  include_examples GroupDocs::Api::Helpers::Status

  subject do
    questionnaire = GroupDocs::Questionnaire.new
    described_class.new(questionnaire: questionnaire)
  end

  it { should respond_to(:id)                   }
  it { should respond_to(:id=)                  }
  it { should respond_to(:guid)                 }
  it { should respond_to(:guid=)                }
  it { should respond_to(:questionnaire)        }
  it { should respond_to(:questionnaire=)       }
  it { should respond_to(:questionnaire_id)     }
  it { should respond_to(:questionnaire_id=)    }
  it { should respond_to(:type)                 }
  it { should respond_to(:type=)                }
  it { should respond_to(:resolved_executions)  }
  it { should respond_to(:resolved_executions=) }
  it { should respond_to(:emails)               }
  it { should respond_to(:emails=)              }
  it { should respond_to(:modified)             }
  it { should respond_to(:modified=)            }

  describe '#initialize' do
    it 'raises error if questionnaire is not specified' do
      -> { described_class.new }.should raise_error(ArgumentError)
    end

    it 'raises error if questionnaire is not an instance of GroupDocs::Questionnaire' do
      -> { described_class.new(questionnaire: '') }.should raise_error(ArgumentError)
    end
  end

  describe '#type=' do
    it 'saves type in machine readable format if symbol is passed' do
      subject.type = :binary
      subject.instance_variable_get(:@type).should == 'Binary'
    end

    it 'does nothing if parameter is not symbol' do
      subject.type = 'Binary'
      subject.instance_variable_get(:@type).should == 'Binary'
    end
  end

  describe '#type' do
    it 'returns converted to human-readable format type' do
      subject.should_receive(:parse_status).with('Embedded').and_return(:embedded)
      subject.type = 'Embedded'
      subject.type.should == :embedded
    end
  end

  describe '#modified' do
    it 'returns converted to Time object Unix timestamp' do
      subject.modified = 1330450135000
      subject.modified.should == Time.at(1330450135)
    end
  end

  describe '#add!' do
    before(:each) do
      mock_api_server(load_json('questionnaire_collectors_add'))
    end

    it 'accepts access credentials hash' do
      lambda do
        subject.add!(client_id: 'client_id', private_key: 'private_key')
      end.should_not raise_error(ArgumentError)
    end

    it 'gets questionnaire id' do
      subject.should_receive(:get_questionnaire_id)
      subject.add!
    end

    it 'updates id and guid with response' do
      lambda do
        subject.add!
      end.should change {
        subject.id
        subject.guid
      }
    end
  end

  describe '#get_questionnaire_id' do
    it 'prefers questionnaire_id over annotation.guid' do
      subject.questionnaire_id = 'abc'
      subject.questionnaire.guid = 'def'
      subject.send(:get_questionnaire_id).should == 'abc'
    end

    it 'returns questionnaire.guid if questionnaire_id is not set' do
      subject.questionnaire.guid = 'def'
      subject.send(:get_questionnaire_id).should == 'def'
    end
  end
end
