class AddCommitTimeToDeploy < ActiveRecord::Migration
  def change
    add_column :deploys, :commit_time, :time
  end
end
