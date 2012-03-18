class ItemComment < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer  :item_id
      t.column   :facebook_id, 'bigint', :null => false
      t.datetime :created_date
      t.text     :comment 
    end
  end

  def self.down
    drop_table :comments
  end
end
