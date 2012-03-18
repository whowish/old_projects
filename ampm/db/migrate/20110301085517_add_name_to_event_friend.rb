class AddNameToEventFriend < ActiveRecord::Migration
  def self.up
    add_column :event_friends, :name, :string, :default=>""
  end

  def self.down
  end
end
