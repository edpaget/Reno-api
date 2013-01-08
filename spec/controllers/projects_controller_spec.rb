require 'spec_helper'

describe ProjectsController do
  describe '#index' do
    before(:each) do
      Project.should_receive(:find).with(:all).and_return([FactoryGirl.create(:project_with_last_commit), FactoryGirl.create(:project), FactoryGirl.create(:project)])
    end

    it 'should call find(:all) on Projects model' do
      get :index
    end

    it 'should assign @projects' do
      get :index
      expect(assigns(:projects)).to have(3).items
    end

    describe 'response' do
      before(:each) do
        get :index
      end

      it 'should be an array of projects' do
        expect(json_response).to be_an(Array)
        expect(json_response).to have(3).items
      end

      it 'should have an array of deploys' do
        expect(json_response.first['deploys']).to be_an(Array)
        expect(json_response.first['deploys']).to have(2).items
      end
    end
  end

  describe "#show" do
    before(:each) do
      Project.should_receive(:find).with(1).and_return(FactoryGirl.create(:project_with_last_commit))
    end

    it 'should call find with the id of the project' do
      get :show, :id => 1
    end

    it 'should assign @project' do
      get :show, :id => 1
      expect(assigns(:project)).to be_a(Project)
    end

    describe 'response' do
      before(:each) do
        get :show, :id => 1
      end

      it 'should have a single project' do
        expect(json_response).to be_a(Hash)
      end
    end
  end

  describe '#create' do
    it 'should call from github webhook on the project model' do
      Project.should_receive(:from_github_webhook)
      post :create, :payload => 'junk'
    end

    it 'should return okay' do
      post :create
      expect(@response.status).to eq(200)
    end
  end

  describe '#update' do
    before(:each) do
      @project = FactoryGirl.build_stubbed(:project)
      Project.should_receive(:find).with(1).and_return(@project)
    end

    it 'should select the project by id' do
      put :update, :id => 1
      expect(assigns(:project)).to be_a(Project)
    end

    describe 'from github' do
      it 'should call update_from_webhook' do
        @project.should_receive(:update_from_webhook)
        put :update, :id => 1, :payload => 'junk'
      end
    end

    describe 'from web' do
      it 'should call update_from_params' do
        @project.should_receive(:update_from_params)
        put :update, :id => 1, :jenkins_url => 'http://example.com'
      end
    end
  end

  describe '#destory' do
    before(:each) do
      @project = FactoryGirl.create(:project)
      Project.should_receive(:find).with(1).and_return(@project)
    end

    it 'should fetch the requested project' do
      delete :destroy, :id => 1
      expect(assigns(:project)).to be_a(Project)
    end

    it 'should call destory on the requeted project' do
      @project.should_receive(:destroy)
      delete :destroy, :id => 1
    end
  end
end
