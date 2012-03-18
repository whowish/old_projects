class CreateFriendPoster < ActiveRecord::Migration
  def self.up
    create_table :friend_posters do |t|
      t.column "image_urls", 'mediumtext', :null =>false
      t.string "friendmage_order_key", :null=>false
      t.integer "gap", :null=>false
      t.integer "border", :null=>false
      t.string "background_color", :null=>false
      t.integer "photo_per_row", :null=>false
      t.datetime "created_date", :null => false
      t.integer "width", :null=>false
      t.integer "height", :null=>false
      t.string "status"
    end
  end

  def self.down
    drop_table :friend_posters
  end
end
