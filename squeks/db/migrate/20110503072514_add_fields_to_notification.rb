class AddFieldsToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :figure_id, :integer
    add_column :notifications, :bid_request_id, :integer
  end

  def self.down
    add_column :notifications, :figure_id
    add_column :notifications, :bid_request_id
  end
end
