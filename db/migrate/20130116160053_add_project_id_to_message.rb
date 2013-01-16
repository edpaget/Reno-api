class AddProjectIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :project_id, :int
  end
end
