# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name "MyProject"
    github_repository "https://github.com/edpaget/my_project"
    jenkins_url "http://ci.zooniverse.org/my_project"
    s3_bucket "MyProject"
  end

  factory :project_with_last_commit, :parent => :project do
    deploys { |g| [ g.association(:deploy), g.association(:last_commit) ] }
  end
end
