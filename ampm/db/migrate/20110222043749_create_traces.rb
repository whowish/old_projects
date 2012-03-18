class CreateTraces < ActiveRecord::Migration
  def self.up
    create_table :traces do |t|
      t.string "facebook_id", :null => false
      t.text "params", :null => false
      t.string "ip_address", :null => false
      t.string "controller_name", :null => false
      t.string "action_name", :null => false
      t.string "result", :null => false
      t.datetime "accessed_date", :null => false
    end
    
    add_column :traces, :browser, :string
    add_column :traces, :decoded_signed_request, :text
    
    add_column :traces, :referer, :text
  end

  def self.down
    drop_table :traces
  end
end
