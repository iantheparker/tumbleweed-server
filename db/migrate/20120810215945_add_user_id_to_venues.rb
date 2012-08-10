class AddUserIdToVenues < ActiveRecord::Migration
  def up
    add_column :venues, :user_id, :integer
  end
  def down
  	remove_column :venues, :user_id, :integer
  end
end
