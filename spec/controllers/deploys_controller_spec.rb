require 'spec_helper'

describe DeploysController do
  describe '#index' do
    before(:each) do
      Deploy.should_receive(:where).with("project_id = ?", 1).and_return([FactoryGirl.create(:deploy)])
    end

    it 'should call Deploy.where with project_id' do
      get :index, :project_id => 1
    end

    it 'should assign deploys with the returned objects' do
      get :index, :project_id => 1
      expect(assigns(:deploys)).to be_an(Array)
    end
  end

  describe "#show" do
    before(:each) do
      Deploy.should_receive(:find).with(1).and_return(FactoryGirl.create(:deploy))
    end

    it 'should call deploy find with the deploy id' do
      get :show, :project_id => 1, :id => 1
    end

    it 'should assign deploy with the return object' do
      get :show, :project_id => 1, :id => 1
      expect(assigns(:deploy)).to be_a(Deploy)
    end
  end

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
