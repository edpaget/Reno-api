class RemovePreviousVersionFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :previous_versions
  end

  def down
    add_column :projects, :previous_versions, :string_array
  end
end
