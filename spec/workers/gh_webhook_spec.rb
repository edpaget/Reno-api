require 'spec_helper'

describe GithubWebhook do
  before(:each) do
    @repo_name = 'egads'
    @user = FactoryGirl.create(:user)
  end

  describe '::perform' do
    before(:each) do
      @client = double('client')
      Octokit::Client.should_receive(:new)
        .with( :login => @user.github_username, :oauth_token => @user.oauth_token )
        .and_return(@client)
    end

    it 'should create a new octokit client' do
      @client.stub!(:create_hook)
      GithubWebhook.perform @user, @repo_name
    end

    it 'should create a new webhook' do
      @client.should_receive(:create_hook)
        .with( @repo_name, "web",
              { :url => "http://zoo-build.herokuapp.com",
                :content_type => 'json' },
              { :events => ['push'],
                :active => true } )
      GithubWebhook.perform @user, @repo_name
    end
  end
  
end
