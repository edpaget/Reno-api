class AddGithubProjectsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_projects, :text
  end
end
