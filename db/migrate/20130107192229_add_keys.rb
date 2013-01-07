class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "deploys", "projects", :name => "deploys_project_id_fk"
  end
end
