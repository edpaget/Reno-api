# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    provider "MyString"
    name "MyString"
    email "MyString"
    oauth_token "MyString"
    github_username "MyString"
    uid "MyString"
  end
end
