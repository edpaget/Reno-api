class Deploy < ActiveRecord::Base
  attr_accessible :commit_message, :commit_user, :git_ref, :time
  belongs_to :project
end
