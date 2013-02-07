class AddWebhookToProject < ActiveRecord::Migration
  def change
    add_column :projects, :webhook, :boolean
  end
end
