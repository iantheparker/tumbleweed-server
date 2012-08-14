class AddOauthTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :oauth_token, :string
  end
  def down
  	remove_column :users, :oauth_token, :string
  end
end
