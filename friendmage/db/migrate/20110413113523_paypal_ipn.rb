class PaypalIpn < ActiveRecord::Migration
  def self.up
    create_table "paypal_ipns", :force => true do |t|
    t.datetime "created_date",         :null => false
    t.string   "remote_host"
    t.integer  "order_id",               :null => false
    t.string   "status",               :null => false
    t.string   "payment_status"
    t.text   "paypal_status"
    t.string   "test_ipn"
    t.string   "transaction_type"
    t.string   "sender_email"
    t.string   "pay_key"
    t.column   "raw",  'mediumtext',                :null => false
    t.column   "error",  'mediumtext'
  end
  end

  def self.down
  end
end
