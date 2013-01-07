class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.time :time
      t.string :git_ref
      t.string :commit_user
      t.string :commit_message

      t.timestamps
    end
  end
end
