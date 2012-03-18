class CancelOrderOldStatus < ActiveRecord::Migration
  def self.up
    add_column :cancel_orders, :old_status, :string
  end

  def self.down
  end
end
