class AddProjectIdToDeploys < ActiveRecord::Migration
  def change
    add_column :deploys, :project_id, :int
  end
end
