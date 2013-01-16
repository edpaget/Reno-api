class Project < ActiveRecord::Base
  attr_accessible :github_repository, :jenkins_url, :name, :s3_bucket, :build_step, :build_dir, :branch
  has_many :deploys, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_and_belongs_to_many :users

  validates :name, :presence => true
  validates :github_repository, :presence => true

  def self.update_from_webhook payload
    project = where("github_respository = ?", payload[:repository][:url])
    if project.nil?
      throw Error
    else
      project.update_last_commit payload
    end
    project
  end

  def self.from_post payload, user
    project = where("github_repository = ?", payload[:url]).first

    if project.nil?
      project = create! do |p|
        p.name = payload[:name]
        p.github_repository = payload[:url]
        p.branch = payload[:branch] 
        p.jenkins_url = payload[:jenkins_url] if payload.has_key? :jenkins_url
        p.s3_bucket = payload[:s3_bucket] if payload.has_key? :s3_bucket
        p.build_step = payload[:build_step] if payload.has_key? :build_step
        p.build_dir = payload[:build_dir] if payload.has_key? :build_dir
      end
      project.set_github_webhook user
      project.retrieve_last_commit user
    end

    project.users.push user unless project.users.include? user
    project
  end

  def set_github_webhook user
    Resque.enqueue GithubWebhook, user.id, self.name
  end

  def retrieve_last_commit user
    Resque.enqueue GithubCommit, user.id, self.id
  end

  def update_last_commit payload
    last_commit.destroy if last_commit

    deploy = deploys.create! do |d|
      d.git_ref = payload[:sha]
      d.commit_message = payload[:commit][:message]
      d.commit_user = payload[:commit][:committer][:name]
      d.commit_time = payload[:commit][:committer][:date]
      d.deploy_status = "last-commit"
    end

    Resque.enqueue GithubTarball, users.first.id, id
  end

  def update_last_commit_from_webhook payload
    last_commit.destroy if last_commit

    deploy = deploys.create! do |d|
      d.git_ref = payload[:after]
      d.commit_message = payload[:commits].last[:message]
      d.commit_user = payload[:commits].last[:author][:name]
      d.commit_time = payload[:commits].last[:timestamp]
      d.deploy_statys = "last-commit"
    end

    Resque.enqueue GithubTarball, users.first.id, id
  end

  def update_from_params params
    params.keep_if { |key, value| [:jenkins_url, :s3_bucket, :build_step, :build_dir].include? key }
    update_attributes! params
    puts self
    self
  end

  def build_project user
    last_commit.build_deploy user if last_commit
  end

  def last_commit
    deploys.select { |d| d.deploy_status == "last-commit" }.first
  end

  def most_recent_deploy
    sorted_deploys = deploys.sort { |left, right| right.build_time <=> left.build_time }
    sorted_deploys.first.build_time
  end

  def owner? user
    users.include? user
  end
end
