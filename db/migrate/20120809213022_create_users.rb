class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.string :device_token
      t.string :foursquare_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
