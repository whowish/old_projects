class AddFriendsOfFriends < ActiveRecord::Migration
  def self.up
    begin
      add_column :facebook_friend_caches, :friends_of_friends, :text,:null=>false
    rescue
    end
  end

  def self.down
  end
end
