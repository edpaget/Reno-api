class AddBuildStepToProject < ActiveRecord::Migration
  def change
    add_column :projects, :build_step, :string
  end
end
