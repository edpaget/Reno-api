# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deploy do
    time "2013-01-07 12:51:41"
    git_ref "MyString"
    commit_user "MyString"
    commit_message "MyString"
  end
end
