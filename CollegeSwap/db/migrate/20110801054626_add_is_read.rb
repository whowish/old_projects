class AddIsRead < ActiveRecord::Migration
  def self.up
    add_column :notifications, :is_read, :boolean
  end

  def self.down
  end
end
