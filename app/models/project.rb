class Project < ActiveRecord::Base
  attr_accessible :github_repository, :jenkins_url, :name, :s3_bucket
  has_many :deploys

  validates :name, :presence => true
  validates :github_repository, :presence => true

  def self.from_github_webhook payload
    project = where("name = :name AND github_repository = :repo_url", 
                    {:name => payload[:repository][:name], 
                     :repo_url => payload[:repository][:url]}).first
    if project
      project.update_from_webhook payload
    else
      create_from_webhook payload
    end
  end

  def self.create_from_webhook payload
    create! do |u|
      u.name = payload[:repository][:name]
      u.github_repository = payload[:repository][:url]
    end
  end

  def update_from_webhook payload
    update_attributes! :name => payload[:repository][:name],
                       :github_repository => payload[:repository][:url]
  end
end
