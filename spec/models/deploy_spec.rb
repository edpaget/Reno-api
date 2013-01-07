require 'spec_helper'

describe Deploy do
  it { should belong_to(:project) }

  describe "#build_deploy" do
    before(:each) do
      @deploy = FactoryGirl.create(:deploy)
    end

    it 'should enqueue a resque process' do
      Resque.should_receive(:enqueue).with(Build, @deploy.id, 'bucket')
      @deploy.build_deploy 'bucket'
    end
  end
end
