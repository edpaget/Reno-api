require 'spec_helper'

describe Project do
  before(:each) do
    @project = FactoryGirl.create(:project)
    @payload = { :repository => { :name => "MyProject",
                                  :url => "https://github.com/edpaget/my_project" },
                 :commits => [ { :id => 'asdfasd', 
                                 :message => "test", 
                                 :author => { :name => "Ed" }, 
                                 :timestamp => "2008-02-15T14:57:17-08:00" } ] }
              
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:github_repository) }
  it { should have_many(:deploys) }

  describe "::from_github_webhook" do
    after(:each) do
      Project.from_github_webhook(@payload)
    end

    it 'should update it the project exists' do
      project = FactoryGirl.create(:project)

      Project.should_receive(:where)
        .with("name = :name AND github_repository = :repo_url",
              {:name => 'MyProject', :repo_url => "https://github.com/edpaget/my_project" })
        .and_return([project])
      project.should_receive(:update_from_webhook)
    end

    it 'should create a new project when the project does not exist' do
      Project.should_receive(:where)
        .with("name = :name AND github_repository = :repo_url",
              {:name => "MyProject", :repo_url => "https://github.com/edpaget/my_project" })
        .and_return([])

      Project.should_receive(:create_from_webhook)
    end
  end

  describe "::create_from_webhook" do
    before(:each) do
      Project.should_receive(:create!).and_return(@project)
    end

    it 'should create a new Project model and save it' do 
      Project.create_from_webhook @payload
    end

    it 'should call update from webhook with the latest commit' do
      @project.should_receive(:update_from_webhook)
      Project.create_from_webhook @payload
    end
  end

  describe "#update_from_webhook" do
    before(:each) do
      @project = FactoryGirl.create(:project_with_last_commit)
      @deploy = FactoryGirl.create(:deploy)
    end

    after(:each) do
      @project.update_from_webhook @payload[:commits].last
    end

    it 'should delete the last-commit' do
      @project.last_commit.should_receive(:destroy)
    end

    it 'should create a new deploy from the most recent commit' do
      @project.deploys.should_receive(:create!).and_return(@deploy)
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
