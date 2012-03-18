class CountFriend < ActiveRecord::Migration
  def self.up
    begin
      add_column :facebook_friend_caches, :friend_count, :integer,:default=>0,:null=>false
    rescue
    end
  
    last_id = 0
    while true
      
      records = FacebookFriendCache.all(:conditions=>["id > ?",last_id],:order=>"id ASC",:limit=>100)
      
      break if records.length == 0
      
      records.each { |f|
        ids = f.friends.split(',')
        f.friend_count = ids.length
        f.save
      }
      
      last_id = records.last.id
    end
  end

  def self.down
  end
end
