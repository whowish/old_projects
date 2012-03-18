class MemberBak < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.column "facebook_id", 'bigint', :null =>false
      t.string "name", :null =>false
      t.string "gender", :null=>false
      t.string "anonymous_name", :null =>false
      t.string "anonymous_profile_pic", :null=>false
      t.boolean "is_anonymous", :default=>false, :null=>false
      t.boolean "is_share_love", :default=>false, :null=>false
      t.boolean "is_share_hate", :default=>false, :null=>false
      t.boolean "is_share_comment", :default=>false, :null=>false
      t.boolean "is_share_comment_agree", :default=>false, :null=>false
      t.boolean "is_share_comment_disagree", :default=>false, :null=>false
    end
  end

  def self.down
    drop_table :members
  end
end
