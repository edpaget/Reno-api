class AddDeployStatusToDeploy < ActiveRecord::Migration
  def change
    add_column :deploys, :deploy_status, :string
    add_column :deploys, :deploy_time, :time
  end
end
