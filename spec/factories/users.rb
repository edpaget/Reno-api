# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    provider "MyString"
    name "MyString"
    email "MyString"
    oauth_token "MyString"
    oauth_secret "MyString"
    uid "MyString"
  end
end
