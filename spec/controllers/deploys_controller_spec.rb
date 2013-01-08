require 'spec_helper'

describe DeploysController do

  describe "#build" do
    before(:each) do
      @deploy = FactoryGirl.build_stubbed(:deploy)
      Deploy.should_receive(:find).with(1).and_return(@deploy)
    end

    it "returns http success" do
      get 'build', :project_id => 1, :deploy_id => 1
      expect(response).to be_success
    end

    it 'should retrieve the requested deploy' do
      get 'build', :project_id => 1, :deploy_id => 1
      expect(assigns(:deploy)).to be_a(Deploy)
    end

    it 'should call build_deploy ont he request deploy' do
      @deploy.should_receive(:build_deploy)
      get 'build', :project_id => 1, :deploy_id => 1
    end
  end

end
