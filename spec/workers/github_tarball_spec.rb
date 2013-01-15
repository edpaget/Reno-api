require 'spec_helper'

describe GithubTarball do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project_with_last_commit)
    Project.stub!(:find).and_return(@project)
    User.stub!(:find).and_return(@user)
  end

  describe '::perform' do
    before(:each) do
      @client = double('client')
      @client.stub!(:archive_link).and_return("http://example.com")
      Octokit::Client.should_receive(:new)
        .with( :login => @user.github_username, :oauth_token => @user.oauth_token )
        .and_return(@client)
      GithubTarball.stub!(:download)
    end

    it 'should create a new github client' do
      GithubTarball.perform @user.id, @project.id
    end

    it 'should retrieve the link to the tarball' do
      @client.should_receive(:archive_link)
        .with(@project.name, :ref => @project.last_commit.git_ref)
        .and_return("http://example.com")
      GithubTarball.perform @user.id, @project.id
    end
  end

  describe '::download' do
  end

  describe '::upload' do
  end
end
