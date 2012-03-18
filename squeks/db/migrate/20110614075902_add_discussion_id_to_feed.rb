class AddDiscussionIdToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :discussion_id,:integer
  end

  def self.down
  end
end
