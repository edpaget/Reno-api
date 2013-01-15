# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deploy do
    commit_time "2013-01-07 12:51:41"
    git_ref "MyString"
    commit_user "MyString"
    commit_message "MyString"
    deploy_status "deployed"
    build_time "2013-01-09 12:25:31"
  end

  factory :last_commit, :parent => :deploy do
    deploy_status "last-commit"
    build_time nil
  end

  factory :recently_built, :parent => :deploy do
    build_time "2013-01-10 12:51:31"
  end
end
