class RemoveDeployTimeFromDeploy < ActiveRecord::Migration
  def up
    remove_column :deploys, :deploy_time
  end

  def down
    add_column :deploys, :deploy_time, :datetime
  end
end
