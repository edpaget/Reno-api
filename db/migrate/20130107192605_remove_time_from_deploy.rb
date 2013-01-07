class RemoveTimeFromDeploy < ActiveRecord::Migration
  def up
    remove_column :deploys, :time
  end

  def down
    add_column :deploys, :time, :time
  end
end
