class MemberCredit < ActiveRecord::Migration
  def self.up
    add_column :members, :credits, :integer,:null => false, :default => 0
  end

  def self.down
    remove_column :members, :credits
  end
end
