class CreateDiscussionLove < ActiveRecord::Migration
  def self.up
    create_table :discussion_love_pendings do |t|
      t.string :status
      t.text :data
      t.string :unique_key
    end
  end

  def self.down
    drop_table :discussion_love_pendings
  end
end
