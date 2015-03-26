require 'spec_helper'

describe GroupDocs::Document::Change do

  it_behaves_like GroupDocs::Api::Entity

  it { should have_accessor(:id)   }
  it { should have_accessor(:type) }
  it { should have_accessor(:box)  }
  it { should have_accessor(:text) }
  it { should have_accessor(:page) }

  describe '#type' do
    it 'returns type as symbol' do
      subject.type = 'delete'
      subject.type.should == :delete
    end
  end

  describe '#box=' do
    it 'converts passed hash to GroupDocs::Document::Rectangle object' do
      subject.box = { :x => 0.90, :y => 0.05, :width => 0.06745, :height => 0.005967 }
      subject.box.should be_a(GroupDocs::Document::Rectangle)
      subject.box.x.should == 0.90
      subject.box.y.should == 0.05
      subject.box.w.should == 0.06745
      subject.box.h.should == 0.005967
    end
  end
  describe '#page=' do
    it 'converts passed hash to GroupDocs::Document::Page object' do
      subject.page = { :Id => 1, :Width => 674, :Height => 596 }
      subject.page.should be_a(GroupDocs::Document::Page)
      subject.page.Id.should == 1
      subject.page.Width.should == 674
      subject.page.Height.should == 596
    end
  end
end
