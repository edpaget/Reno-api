class Deploy < ActiveRecord::Base
  attr_accessible :commit_message, :commit_user, :git_ref, :commit_time, :deploy_status
  belongs_to :project

  def build_deploy bucket, build_step, build_dir
    Resque.enqueue Build, id, bucket, build_step, build_dir
  end
end
