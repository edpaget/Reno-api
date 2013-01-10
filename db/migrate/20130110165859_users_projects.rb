class UsersProjects < ActiveRecord::Migration
  def up
    create_table :users_projects do |t|
      t.references :user, :null => false
      t.references :project, :null => false
    end
  end

  def down
    drop_table :users_projects
  end
end
