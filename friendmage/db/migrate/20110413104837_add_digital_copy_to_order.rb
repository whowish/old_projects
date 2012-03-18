class AddDigitalCopyToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :buy_digital_copy, :boolean
    add_column :orders, :buy_print_copy, :boolean
  end

  def self.down
  end
end
