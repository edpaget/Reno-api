class RemoveLastDeployFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :last_deploy
  end

  def down
    add_column :projects, :last_deploy, :time
  end
end
