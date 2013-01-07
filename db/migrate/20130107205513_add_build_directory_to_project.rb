class AddBuildDirectoryToProject < ActiveRecord::Migration
  def change
    add_column :projects, :build_dir, :string
  end
end
