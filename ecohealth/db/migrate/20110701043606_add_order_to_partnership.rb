class AddOrderToPartnership < ActiveRecord::Migration
  def self.up
    add_column :partners, :ordered_number, :integer
  end

  def self.down
    remove_column :partners, :ordered_number
  end
end
