class Notifications < ActiveRecord::Migration
  
  ACTION_AGREE = "AGREE"
  ACTION_REPLY = "REPLY"
  
  
  def self.up
    create_table :notifications do |t|
      t.datetime "created_date", :null=>false
      t.column "notified_facebook_id", 'bigint', :null =>false
      t.column "facebook_id", 'bigint', :null =>false
      t.integer "comment_id"
      t.string "action"
      t.text "data"
      t.boolean "is_anonymous"
    end
  end

  def self.down
    drop_table :notifications
  end
end
