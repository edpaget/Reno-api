class AddBuildTimeToDeploy < ActiveRecord::Migration
  def change
    add_column :deploys, :build_time, :datetime
  end
end
