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
      project.update_from_webhook payload[:commits].last
    else
      create_from_webhook payload
    end
  end

  def self.create_from_webhook payload
    project = create! do |p|
      p.name = payload[:repository][:name]
      p.github_repository = payload[:repository][:url]
    end
    project.update_from_webhook payload[:commits].last
  end

  def update_from_webhook payload
    last_commit.destroy if last_commit

    deploy = deploys.create! do |d|
      d.git_ref = payload[:id]
      d.commit_message = payload[:message]
      d.commit_user = payload[:author][:name]
      d.commit_time = payload[:timestamp]
      d.deploy_status = "last-commit"
    end
  end

  def update_from_params params
    update_attributes! :jenkins_url => params[:jenkins_url],
                       :s3_bucket => params[:s3_bucket]
  end

  def build_project
    last_commit.build_deploy s3_bucket
  end

  def last_commit
    deploys.select { |d| d.deploy_status == "last-commit" }.first
  end
end
