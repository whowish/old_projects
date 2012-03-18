class FriendCache < ActiveRecord::Migration
  def self.up
    create_table :friend_caches do |t|
      t.integer "crypto_id", :null =>false
      t.text "friends", :null =>false
      t.datetime "updated_date", :null=>false
    end
  end

  def self.down
    drop_table :friend_caches
  end
end
