require 'spec_helper'

describe Project do
  before(:each) do
    @payload = { :repository => { :name => "MyProject",
                                  :url => "https://github.com/edpaget/my_project" }}
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
    it 'should create a new Project model and save it' do 
      Project.should_receive(:create!)
      Project.create_from_webhook @payload
    end
  end

  describe "#update_from_webhook" do
    before(:each) do
      @project = FactoryGirl.create(:project)
    end

    it 'should update the projects name and url' do
      @project.should_receive(:update_attributes!)
      @project.update_from_webhook @payload 
    end
  end
end
