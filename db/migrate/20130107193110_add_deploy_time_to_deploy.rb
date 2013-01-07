class AddDeployTimeToDeploy < ActiveRecord::Migration
  def change
    add_column :deploys, :commit_time, :datetime
    add_column :deploys, :deploy_time, :datetime
  end
end
