class Project < ActiveRecord::Base
  attr_accessible :github_repository, :jenkins_url, :name, :s3_bucket, :build_step, :build_dir
  has_many :deploys
  has_and_belongs_to_many :users

  validates :name, :presence => true
  validates :github_repository, :presence => true

  def self.update_from_webhook payload
    project = where("github_respository = ?", payload[:repository][:url])
    if project.nil?
      throw Error
    else
      project.update_last_commit payload[:commits].last
    end
    project
  end

  def self.from_post payload, user
    project = create! do |p|
      p.name = payload[:name]
      p.github_repository = payload[:url]
      p.branch = payload[:branch] 
    end
    project.users.push user
    project.save!

    project.update_last_commit payload[:commit]
    Resque.enqueue(GithubWebhook, project.users.first, project.name)
    project
  end

  def update_last_commit payload
    last_commit.destroy if last_commit

    deploy = deploys.create! do |d|
      d.git_ref = payload[:id]
      d.commit_message = payload[:message]
      d.commit_user = payload[:author][:name]
      d.commit_time = payload[:timestamp]
      d.deploy_status = "last-commit"
    end

    Resque.enqueue(GithubTarball, users.first, payload[:id])
  end

  def update_from_params params
    params.keep_if { |key, value| [:jenkins_url, :s3_bucket, :build_step, :build_dir].include? key }
    update_attributes! params
  end

  def build_project
    last_commit.build_deploy if last_commit
  end

  def last_commit
    deploys.select { |d| d.deploy_status == "last-commit" }.first
  end
end
