class AddRenoTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :reno_token, :string, :unique => true
  end
end
