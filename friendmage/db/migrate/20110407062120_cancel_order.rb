class CancelOrder < ActiveRecord::Migration
  def self.up
    create_table :cancel_orders do |t|
      t.integer "order_id", :null=>false
      t.string  "reason"
      t.string  "cus_account_number"
      t.datetime "created_date", :null => false
    end
  end

  def self.down
    drop_table :cancel_orders
  end
end
