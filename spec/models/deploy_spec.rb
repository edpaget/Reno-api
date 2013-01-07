require 'spec_helper'

describe Deploy do
  it { should belong_to(:project) }

  describe "#build_deploy" do
    before(:each) do
      @deploy = FactoryGirl.create(:deploy)
    end

    it 'should enqueue a resque process' do
      Resque.should_receive(:enqueue).with(Build, @deploy.id, 'bucket', 'ruby build.rb', 'build/')
      @deploy.build_deploy 'bucket', 'ruby build.rb', 'build/'
    end
  end
end
