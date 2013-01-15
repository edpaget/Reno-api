class Deploy < ActiveRecord::Base
  attr_accessible :commit_message, :commit_user, :git_ref, :commit_time, :deploy_status, :build_time
  belongs_to :project

  def build_deploy
    Resque.enqueue Build, id
  end
end
