class Feeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.datetime "created_date", :null=>false
      t.column "facebook_id", 'bigint'
      t.integer "figure_id"
      t.integer "comment_id"
      t.integer "figure_image_id"
      t.string "action"
      t.text "data"
      t.boolean "is_anonymous"
    end
  end

  def self.down
    drop_table :feeds
  end
end
