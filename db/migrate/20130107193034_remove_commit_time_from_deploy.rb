class RemoveCommitTimeFromDeploy < ActiveRecord::Migration
  def up
    remove_column :deploys, :commit_time
    remove_column :deploys, :deploy_time
  end

  def down
    add_column :deploys, :deploy_time, :time
    add_column :deploys, :commit_time, :time
  end
end
