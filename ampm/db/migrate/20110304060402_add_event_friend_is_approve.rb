class AddEventFriendIsApprove < ActiveRecord::Migration
  def self.up
    add_column :event_friends, :is_approved, :integer, :default=>1
    add_column :event_friends, :invited_by, :string, :default=>""
  end

  def self.down
  end
end
