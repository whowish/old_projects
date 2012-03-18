class MemberIsaesir < ActiveRecord::Migration
  def self.up
    add_column :members, :is_aesir, :boolean,:null => false, :default => false
  end

  def self.down
    remove_column :members, :is_aesir
  end
end
