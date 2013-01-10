class RemoveGithubProjectsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :github_projects
  end

  def down
    add_column :users, :github_projects, :text
  end
end
