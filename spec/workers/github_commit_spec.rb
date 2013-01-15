require 'spec_helper'

describe GithubCommit do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project)
  end

  describe '::perform' do
    before(:each) do
      @client = double('client')
      Octokit::Client.should_receive(:new)
        .with( :login => @user.github_username, :oauth_token => @user.oauth_token )
        .and_return(@client)
      @client.should_receive(:commits).with(@project.name, @project.branch)
        .and_return([ { :commit => 'blah' } ])
      @project.should_receive(:update_last_commit)
    end

    it 'should create a new github client' do
      GithubCommit.perform @user, @project
    end

    it 'should download all commits' do
      GithubCommit.perform @user, @project
    end

    it 'should call update_last_commit' do
      GithubCommit.perform @user, @project
    end
  end
end
