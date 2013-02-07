class User < ActiveRecord::Base
  attr_accessible :email, :name, :oauth_token, :provider, :uid, :github_username, :image
  has_and_belongs_to_many :projects
  has_many :messages

  before_create :generate_token

  validates_presence_of :name
  validates_presence_of :oauth_token
  validates_presence_of :github_username
  validates_presence_of :uid 

  def self.find_or_create_from_omniauth auth
    user = find_by_uid auth[:uid]
    if user.nil?
      user = create! do |u|
        u.uid = auth[:uid]
        u.provider = auth[:provider]
        u.email = auth[:info][:email]
        u.name = auth[:info][:name]
        u.oauth_token = auth[:credentials][:token]
        u.github_username = auth[:info][:nickname]
        u.image = auth[:info][:image]
      end
    elsif user.changed_credentials? auth[:credentials]
      new_credentials = { :oauth_token => auth[:credentials][:token] }
      user.update_attributes!  new_credentials
    end
    return user
  end

  def changed_credentials? credentials
    !(oauth_token == credentials[:token])
  end

  private

  def generate_token
    begin
      self.reno_token = SecureRandom.hex
    end while self.class.exists? reno_token: reno_token
  end
end
