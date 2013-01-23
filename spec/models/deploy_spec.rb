require 'spec_helper'

describe Deploy do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @deploy = FactoryGirl.create(:deploy)
    @user = FactoryGirl.create(:user)
  end

  it { should belong_to(:project) }

  describe "#build_deploy" do
    it 'should enqueue a resque process' do
      Resque.should_receive(:enqueue).with(Build, @deploy.id, @user.id)
      @deploy.build_deploy @user
    end
  end

  describe "#remove_tarball" do
    it 'should enqueue a resque process to delete the tarball' do
      Resque.should_receive(:enqueue).with(DeleteTarball, @project.name, @project.deploys.first.git_ref)
      @project.deploys.first.destroy
    end
  end
end
