require 'spec_helper'

describe Project do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @user = FactoryGirl.create(:user)
    @payload = { :name => "MyProject",
                 :url => "https://github.com/edpaget/my_project",
                 :branch => "master",
                 :sha => 'askdlj;faskdjf',
                 :commit => { :id => 'asdfasd', 
                               :message => "test", 
                               :committer => { :name => "Ed",
                                              :date => "2011-04-14T16:00:49Z" }, 
                               :timestamp => "2008-02-15T14:57:17-08:00" }}
              
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:github_repository) }
  it { should have_many(:deploys) }
  it { should have_many(:messages) }
  it { should have_and_belong_to_many(:users) }

  describe "::update_from_webhook" do
    before(:each) do
      Project.should_receive(:where).and_return(@project)
    end

    it 'should  call update last commit on the project' do
      @project.should_receive(:update_last_commit)
      Project.update_from_webhook :repository => { :url => 'http://example.com' }, :commits => [ 'hey' ]
    end
  end

  describe "::from_post" do
    before(:each) do
      Resque.stub!(:enqueue)
      Project.stub!(:where).and_return(nil)
    end

    it 'should check if the project has already been created' do
      Project.should_receive(:where).with("github_repository = ?", "https://github.com/edpaget/my_project").and_return([@project])
      Project.from_post @payload, @user
    end

    it 'should create a new Project model and save it' do 
      Project.stub!(:where).and_return([])
      Project.should_receive(:create!).and_return(@project)
      Project.from_post @payload, @user
    end
  end

  describe "#retrieve_last_commit" do
    it 'should queue a process to set up github webhook' do
      Resque.should_receive(:enqueue).with(GithubCommit, @user.id, @project.id)
      @project.retrieve_last_commit @user
    end
  end

  describe "#set_github_webhook" do
    it 'should queue a process to retreive the last commit' do
      Resque.should_receive(:enqueue).with(GithubWebhook, @user.id, @project.name)
      @project.set_github_webhook @user
    end
  end

  describe "#update_last_commit" do
    before(:each) do
      @project = FactoryGirl.create(:project_with_last_commit)
      @deploy = FactoryGirl.create(:deploy)
      @project.last_commit.stub!(:destroy)
    end

    after(:each) do
      @project.update_last_commit @payload
    end

    it 'should delete the last-commit' do
      @project.last_commit.should_receive(:destroy)
    end

    it 'should create a new deploy from the most recent commit' do
      @project.deploys.should_receive(:create!).and_return(@deploy)
    end

    it 'should queue the tarball downloader' do
      Resque.should_receive(:enqueue).with(GithubTarball, @project.users.first.id, @project.id)
    end
  end

  describe "#update_from_params" do
    it "should call update_attributes" do
      @project.should_receive(:update_attributes!)
      @project.update_from_params({ :jenkins_url => 'aasfd', :s3_bucket => 'bucket_name', :build_dir => 'public'})
    end
  end

  describe "#build_project" do
    it 'should invoke the build method on the deploy with the last-commit status' do
      deploy = FactoryGirl.create(:last_commit)
      deploy.should_receive(:build_deploy)

      @project.deploys << deploy
      @project.build_project @user
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

  describe '#owner?' do
    it 'should return true if project owner is user' do
      user = FactoryGirl.create(:user)
      @project.users.push user
      expect(@project.owner?(user)).to be_true
    end

    it 'should return false otherwise' do
      user = FactoryGirl.create(:user)
      expect(@project.owner?(user)).to be_false
    end
  end

  describe '#most_recent_deploy' do
    it 'should return a string of the most recent deploy' do
      expect(@project.most_recent_deploy).to eq("2013-01-10 12:51:31")
    end
  end

  describe '#update_from_webhook' do
  end
end
