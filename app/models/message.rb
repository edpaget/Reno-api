class Message < ActiveRecord::Base
  attr_accessible :text, :status
  belongs_to :user
  belongs_to :project

  def self.from_build status, text, user, project
    message = create! :status => status, :text => text
    message.user = user
    message.project = project
    message if message.save!
  end
end
