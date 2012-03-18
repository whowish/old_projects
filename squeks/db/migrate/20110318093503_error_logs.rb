class ErrorLogs < ActiveRecord::Migration
  def self.up
    create_table :error_logs, :force => true do |t|
      t.datetime "time",        :null => false
      t.string   "ip_address"
      t.string   "identifier",  :null => false
      t.text     "description", :null => false
    end
  end

  def self.down
    drop_table :error_logs
  end
end
