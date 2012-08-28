class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
    	t.integer :id
    	t.integer :user_id
    	t.string :checkin_id
    	t.string :milestone_id
    	t.string :venue_name
    	t.string :venue_category
    	t.string :venue_id
    	t.datetime :created_at
    	t.datetime :updated_at
      
      t.timestamps
    end
  end
end
