require 'spec_helper'

describe ProjectsController do
  describe '#index' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      session[:user_id] = @user.id
      @user.should_receive(:projects)
        .and_return([FactoryGirl.create(:project_with_last_commit), 
                     FactoryGirl.create(:project), 
                     FactoryGirl.create(:project)])

      User.stub!(:find).and_return(@user)
    end

    it 'should call projects on the current_user' do
      get :index
    end

    it 'should assign @projects' do
      get :index
      expect(assigns(:projects)).to have(3).items
    end

    describe 'when no user is logged in' do
      before(:each) do
        @user.rspec_reset
        session[:user_id] = nil
      end

      it 'should return not authorized' do
        get :index
        expect(response.status).to eq(401)
      end
    end

    describe 'response' do
      before(:each) do
        get :index
      end

      it 'should be an array of projects' do
        expect(json_response).to be_an(Array)
        expect(json_response).to have(3).items
      end

      it 'should have the last commit' do
        expect(json_response.first['last_commit']).to be_a(Hash)
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

    it 'should call destory on the requested project' do
      @project.should_receive(:destroy)
      delete :destroy, :id => 1
    end
  end

  describe '#build' do
    before(:each) do
      @project = FactoryGirl.build_stubbed(:project)
      Project.should_receive(:find).with(1).and_return(@project)
    end

    it 'should fetch the requested project' do
      get :build, :project_id => 1
      expect(assigns(:project)).to be_a(Project)
    end

    it 'should call build on the requested project' do
      @project.should_receive(:build_project)
      get :build, :project_id => 1
    end
  end
end
