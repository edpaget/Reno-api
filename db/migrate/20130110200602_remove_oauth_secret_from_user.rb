class RemoveOauthSecretFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :oauth_secret
  end

  def down
    add_column :users, :oauth_secret, :string
  end
end
