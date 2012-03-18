class AddMemberStatus < ActiveRecord::Migration
  def self.up
    add_column :members,:status, :string,:default=>Member::STATUS_ACTIVE,:null=>false
  end

  def self.down
  end
end
