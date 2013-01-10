class User < ActiveRecord::Base
  attr_accessible :email, :name, :oauth_secret, :oauth_token, :provider, :uid
  has_and_belongs_to_many :projects
end
