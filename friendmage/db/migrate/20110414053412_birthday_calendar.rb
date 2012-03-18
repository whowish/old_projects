class BirthdayCalendar < ActiveRecord::Migration
 def self.up
    create_table :birthday_calendars do |t|
      t.column "birthday_information",'mediumtext', :null =>false
      t.string "friendmage_order_key", :null=>false
      t.integer "offset_x", :null=>false
      t.integer "offset_y", :null=>false
      t.integer "gap_x", :null=>false
      t.integer "gap_y", :null=>false
      t.integer "year", :null=>false
      t.string "background_color", :null=>false
      t.string "mode", :null=>false
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
