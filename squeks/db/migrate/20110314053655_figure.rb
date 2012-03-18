class Figure < ActiveRecord::Migration
  def self.up
    create_table :figures do |t|
      t.string   :title, :null => false
      t.text   :description
      t.string   :default_pic
      t.datetime :created_date
      t.string   :status
      t.integer  :loves, :null => false, :default => 0
      t.integer  :hates, :null => false, :default => 0
      t.integer  :dont_cares, :null => false, :default => 0
      t.integer  :views, :null => false, :default => 0
    end
    create_table :tags do |t|
      t.string  :name
      t.integer :parent_id
    end
    create_table :figure_tags do |t|
      t.integer :figure_id
      t.integer :tag_id
    end
    
    create_table :comments do |t|
      t.integer  :figure_id
      t.column   :facebook_id, 'bigint', :null => false
      t.datetime :created_date
      t.text     :comment 
      t.integer  :agrees , :null => false, :default => 0
      t.integer  :disagrees, :null => false, :default => 0
      t.integer  :parent_id, :null => false, :default => 0
      t.boolean  :is_anonymous , :null => false, :default => false
    end
    
    create_table :figure_loves do |t|
      t.integer  :figure_id
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :love_type      
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end
    
    create_table :comment_agrees do |t|
      t.integer  :comment_id
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :agree_type
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end
  end

  def self.down
    drop_table :comment_agrees
    drop_table :figure_loves
    drop_table :comments
    drop_table :figure_tags
    drop_table :tags
    drop_table :figures
  end
end
