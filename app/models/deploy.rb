class Deploy < ActiveRecord::Base
  attr_accessible :commit_message, :commit_user, :git_ref, :commit_time, :deploy_status, :build_time
  belongs_to :project

  before_destroy :remove_tarball

  def build_deploy user
    Resque.enqueue Build, id, user.id
  end

  private
  
  def remove_tarball
    Resque.enqueue DeleteTarball, project.name, git_ref
  end
end
