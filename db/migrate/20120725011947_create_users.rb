class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :device_token
      t.string :foursquare_id

      t.timestamps
    end
  end
end
