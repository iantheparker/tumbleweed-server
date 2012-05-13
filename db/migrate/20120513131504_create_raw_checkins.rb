class CreateRawCheckins < ActiveRecord::Migration
  def change
    create_table :raw_checkins do |t|
      t.text :payload

      t.timestamps
    end
  end
end
