class CreateComment < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :event_id
      t.string :facebook_id
      t.datetime :created_date
      t.text     :comment 
      t.integer  :like
    end
    
    create_table :comment_likes do |t|
      t.integer :comment_id
      t.string :facebook_id
      t.datetime :created_date
    end
  end

  def self.down
    drop_table :comment_likes
    drop_table :comments
  end
end
