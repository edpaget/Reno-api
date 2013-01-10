class User < ActiveRecord::Base
  attr_accessible :email, :name, :oauth_secret, :oauth_token, :provider, :uid
  has_and_belongs_to_many :projects

  serialize :github_projects, Hash

  validates_presence_of :name
  validates_presence_of :oauth_secret
  validates_presence_of :oauth_token
  validates_presence_of :uid 

  def self.find_or_create_from_omniauth auth
    user = find_by_uid auth[:uid]
    if user.nil?
      user = create! do |u|
        u.uid auth[:uid]
        u.provider auth[:provider]
        u.email auth[:info][:email]
        u.name auth[:info][:name]
        u.oauth_secret auth[:credentials][:secret]
        u.oauth_token auth[:credentials][:token]
      end
    elsif user.changed_credentials? auth[:credentials]
      new_credentials = { :oauth_secret => auth[:credentials][:secret],
                          :oauth_token => auth[:credentials][:token] }
      user.update_attributes!  new_credentials

    end
    puts user
    Resque.enqueue GithubProjectList, user.id
    return user
  end

  def changed_credentials? credentials
    !((oauth_token == credentials[:token]) && (oauth_secret == credentials[:secret]))
  end
end
