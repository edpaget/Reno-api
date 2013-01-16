require 'spec_helper'

describe Message do
  it { should belong_to(:user) }
  it { should belong_to(:project) }

  describe "::from_build" do
    it "should call create!" do
      status = "Build failed!"
      text = "Console output of failure" 
      user = FactoryGirl.create(:user)
      project = FactoryGirl.create(:project)

      Message.should_receive(:create!).with(:status => status, :text => text)
        .and_return(FactoryGirl.create(:message))
      Message.from_build status, text, user, project
    end

  end
end
