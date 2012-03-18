class AddNotificationModel < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :notified_facebook_id
      t.string :facebook_id
      t.integer :item_id
      t.datetime :created_date
    end
    
    add_index :notifications,:notified_facebook_id
  end

  def self.down
    drop_table :notifications
  end
end
