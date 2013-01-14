# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name "zooniverse/MyProject"
    github_repository "https://github.com/edpaget/my_project"
    jenkins_url "http://ci.zooniverse.org/my_project"
    s3_bucket "MyProject"
    build_step "ruby build.rb"
    build_dir "build/"
    branch "master"
    users { |g| [ g.association(:user) ] }
  end

  factory :project_with_last_commit, :parent => :project do
    deploys { |g| [ g.association(:deploy), g.association(:last_commit) ] }
  end
end
