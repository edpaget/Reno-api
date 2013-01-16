class Deploy < ActiveRecord::Base
  attr_accessible :commit_message, :commit_user, :git_ref, :commit_time, :deploy_status, :build_time
  belongs_to :project

  before_destroy :remove_tarball

  def build_deploy
    Resque.enqueue Build, id
  end

  private
  
  def remove_tarball
    Resque.enqueue DeleteTarball, id
  end
end
