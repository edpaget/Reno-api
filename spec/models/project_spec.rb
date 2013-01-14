require 'spec_helper'

describe Project do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @payload = { :name => "MyProject",
                 :url => "https://github.com/edpaget/my_project",
                 :branch => "master",
                 :commit => { :id => 'asdfasd', 
                               :message => "test", 
                               :author => { :name => "Ed" }, 
                               :timestamp => "2008-02-15T14:57:17-08:00" }}
              
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:github_repository) }
  it { should have_many(:deploys) }
  it { should have_and_belong_to_many(:users) }

  describe "::update_from_webhook" do
    before(:each) do
      Project.should_receive(:where).and_return(@project)
    end
  end

  describe "::from_post" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      Project.should_receive(:create!).and_return(@project)
      @project.should_receive(:update_last_commit)
    end

    it 'should create a new Project model and save it' do 
      Project.from_post @payload, @user
    end

    it 'should call update last commit with the latest commit' do
      Project.from_post @payload, @user
    end

    it 'should queue a process to set up github webhook' do
      Resque.should_receive(:enqueue).with(GithubWebhook, @project.users.first, @project.name)
      Project.from_post @payload, @user
    end
  end

  describe "#update_last_commit" do
    before(:each) do
      @project = FactoryGirl.create(:project_with_last_commit)
      @deploy = FactoryGirl.create(:deploy)
    end

    after(:each) do
      @project.update_last_commit @payload[:commit]
    end

    it 'should delete the last-commit' do
      @project.last_commit.should_receive(:destroy)
    end

    it 'should create a new deploy from the most recent commit' do
      @project.deploys.should_receive(:create!).and_return(@deploy)
    end

    it 'should queue the tarball downloader' do
      Resque.should_receive(:enqueue).with(GithubTarball, @project.users.first, @payload[:commit][:id])
    end
  end

  describe "#update_from_params" do
    it "should call update_attributes" do
      @project.should_receive(:update_attributes!)
      @project.update_from_params({ :jenkins_url => 'aasfd', :s3_bucket => 'bucket_name'})
    end
  end

  describe "#build_project" do
    it 'should invoke the build method on the deploy with the last-commit status' do
      deploy = FactoryGirl.create(:last_commit)
      deploy.should_receive(:build_deploy)

      @project.deploys << deploy
      @project.build_project
    end
  end

  describe "#last_commit" do
    before(:each) do
      @project = FactoryGirl.create(:project_with_last_commit)
      @deploy = FactoryGirl.create(:last_commit)
    end

    it 'should find the deploy model with the last-commit status' do
      @project.last_commit.deploy_status.should eq("last-commit")
    end
  end
end
