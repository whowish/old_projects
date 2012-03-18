class CreateHistory < ActiveRecord::Migration
  def self.up
    create_table :history_figures do |t|
      t.string   :title, :null => false
      t.string   :description
      t.string   :default_pic
      t.datetime :created_date
      t.string   :status
      t.integer  :loves, :null => false, :default => 0
      t.integer  :hates, :null => false, :default => 0
      t.integer  :dont_cares, :null => false, :default => 0
      t.integer  :views, :null => false, :default => 0
      t.integer  :main_figure_id , :null => false
    end
    
    create_table :history_figure_tags do |t|
      t.integer :figure_id
      t.integer :tag_id
    end
    
    create_table :history_figure_pictures do |t|
      t.integer  :figure_id
      t.string   :original_image_path
    end
    
    create_table :history_comments do |t|
      t.integer  :figure_id
      t.column   :facebook_id, 'bigint', :null => false
      t.datetime :created_date
      t.text     :comment 
      t.integer  :agrees , :null => false, :default => 0
      t.integer  :disagrees, :null => false, :default => 0
      t.integer  :parent_id, :null => false, :default => 0
      t.boolean  :is_anonymous , :null => false, :default => false
    end
    
    create_table :history_figure_loves do |t|
      t.integer  :figure_id
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :love_type      
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end
  end

  def self.down
    drop_table :history_figure_loves
    drop_table :history_comments
    drop_table :history_figure_pictures
    drop_table :history_figure_tags
    drop_table :history_figures
  end
end
