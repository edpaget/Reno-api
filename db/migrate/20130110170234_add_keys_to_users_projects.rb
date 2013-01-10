class AddKeysToUsersProjects < ActiveRecord::Migration
  def change
    rename_table :users_projects, :projects_users
    add_foreign_key "projects_users", "projects", :name => "projects_users_project_id_fk"
    add_foreign_key "projects_users", "users", :name => "projects_users_user_id_fk"
  end
end
