class OrderPaypalKey < ActiveRecord::Migration
  def self.up
    add_column :orders, :paypal_pay_key, :string
  end

  def self.down
  end
end
