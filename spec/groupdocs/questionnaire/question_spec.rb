require 'spec_helper'

describe GroupDocs::Questionnaire::Question do

  it_behaves_like GroupDocs::Api::Entity

  describe 'TYPES' do
    it 'contains hash of field types' do
      described_class::TYPES.should == {
        simple:          0,
        multiple_choice: 1,
      }
    end
  end

  it { should respond_to(:field)       }
  it { should respond_to(:field=)      }
  it { should respond_to(:text)        }
  it { should respond_to(:text=)       }
  it { should respond_to(:def_answer)  }
  it { should respond_to(:def_answer=) }
  it { should respond_to(:required)    }
  it { should respond_to(:required=)   }
  it { should respond_to(:type)        }
  it { should respond_to(:type=)       }
  it { should respond_to(:answers)     }
  it { should respond_to(:answers=)    }

  describe '#answers=' do
    it 'converts each answer to GroupDocs::Questionnaire::Question::Answer object' do
      subject.answers = [{ text: 'Text1', value: 'Value1' }, { text: 'Text2', value: 'Value2' }]
      answers = subject.answers
      answers.should be_an(Array)
      answers.each do |answer|
        answer.should be_a(GroupDocs::Questionnaire::Question::Answer)
      end
    end

    it 'saves each answer if it is GroupDocs::Questionnaire::Question::Answer object' do
      answer1 = GroupDocs::Questionnaire::Question::Answer.new(text: 'text1')
      answer2 = GroupDocs::Questionnaire::Question::Answer.new(text: 'text2')
      subject.answers = [answer1, answer2]
      subject.answers.should include(answer1)
      subject.answers.should include(answer2)
    end

    it 'does nothing if nil is passed' do
      lambda do
        subject.answers = nil
      end.should_not change(subject, :answers)
    end
  end

  describe '#add_answer' do
    it 'raises error if answer is not GroupDocs::Questionnaire::Question::Answer object' do
      -> { subject.add_answer('Answer') }.should raise_error(ArgumentError)
    end

    it 'saves answer' do
      answer = GroupDocs::Questionnaire::Question::Answer.new(text: 'Text', value: 'Value')
      subject.add_answer(answer)
      subject.answers.should == [answer]
    end
  end

  describe '#type=' do
    it 'saves type in machine readable format if symbol is passed' do
      subject.type = :multiple_choice
      subject.instance_variable_get(:@type).should == 1
    end

    it 'does nothing if parameter is not symbol' do
      subject.type = 1
      subject.instance_variable_get(:@type).should == 1
    end
  end

  describe '#type' do
    it 'returns type in human-readable format' do
      subject.type = 1
      subject.type.should == :multiple_choice
    end
  end
end