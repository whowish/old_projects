class AddIndexToNotification < ActiveRecord::Migration
  def self.up
    add_index :notifications, [:notified_facebook_id,:is_read]
    add_index :requests, [:responder_facebook_id,:status]
    add_index :requests, [:requestor_facebook_id,:is_read,:status]
  end

  def self.down
  end
end
