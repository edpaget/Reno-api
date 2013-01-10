class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :name
      t.string :email
      t.string :oauth_token
      t.string :oauth_secret
      t.string :uid

      t.timestamps
    end
  end
end
