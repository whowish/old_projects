class CreateDiscussion < ActiveRecord::Migration
  def self.up
    create_table :discussions do |t|
      t.string   :title, :null => false
      t.text     :description
      t.datetime :created_date
      t.string   :status
      t.integer  :loves, :null => false, :default => 0
      t.integer  :hates, :null => false, :default => 0
      t.integer  :views, :null => false, :default => 0
      t.integer  :dont_cares, :null => false, :default => 0
      t.integer  :replies, :null => false, :default => 0
      t.column   :creator_facebook_id, 'bigint', :null => false
      t.boolean  :is_anonymous, :null => false, :default => false
    end
    
    create_table :discussion_loves do |t|
      t.integer  :discussion_id, :null => false
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :love_type      
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end
    
    create_table :discussion_figures do |t|
      t.integer  :discussion_id, :null => false
      t.integer  :figure_id, :null => false
      t.datetime :created_date
      t.string   :discussion_side
    end
    
    create_table :discussion_comments do |t|
      t.integer  :discussion_id
      t.column   :facebook_id, 'bigint', :null => false
      t.datetime :created_date
      t.text     :comment 
      t.integer  :agrees , :null => false, :default => 0
      t.integer  :disagrees, :null => false, :default => 0
      t.integer  :parent_id, :null => false, :default => 0
      t.boolean  :is_anonymous , :null => false, :default => false
      t.integer  :total_agree , :null => false, :default => 0
      t.string   :status
    end
    
    create_table :discussion_comment_agrees do |t|
      t.integer  :discussion_comment_id
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :agree_type
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end

  end

  def self.down
    drop_table :discussion_comment_agrees
    drop_table :discussion_comments
    drop_table :discussion_figures
    drop_table :discussion_loves
    drop_table :discussions
  end
end
