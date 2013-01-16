class AddKeysToMessages < ActiveRecord::Migration
  def change
    add_foreign_key "messages", "projects", :name => "messages_project_id_fk"
    add_foreign_key "messages", "users", :name => "messages_user_id_fk"
  end
end
