class AddLevelToUsers < ActiveRecord::Migration
def up
    change_table :users do |t|
      t.integer :level, :default => 0
    end
  end
 
  def down
    remove_column :users, :level
  end
end