class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :github_repository
      t.string :jenkins_url
      t.string :s3_bucket
      t.time :last_deploy

      t.timestamps
    end
  end
end
