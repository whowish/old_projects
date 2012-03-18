class AddFriendRecord < ActiveRecord::Migration
  def self.up
    create_table :facebook_friend_records do |t|
      t.string "facebook_id", :null => false
      t.string "friend_id", :null => false
      t.string "name", :null => false
    end
  end

  def self.down
    drop_table :facebook_friends_records
  end
end
