class AddIsRead_ < ActiveRecord::Migration
  def self.up
    add_column :notifications,:is_read,:boolean,:default=>false,:null=>false
  end

  def self.down
    remove_column :notifitions,:is_read
  end
end
