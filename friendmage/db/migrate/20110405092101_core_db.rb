class CoreDb < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.column "facebook_id", 'bigint', :null =>false
      t.string "name", :null =>false
      t.string "gender", :null=>false
      t.datetime "updated_date", :null => false
      t.string  "recipient_name"
      t.string  "address_identifier"
      t.string  "address_street"
      t.string  "address_subdistrict"                                    
      t.string  "address_district"                                    
      t.string  "address_province"                                    
      t.string  "address_postal_code"
      t.boolean "is_aesir" , :null => false, :default => false
    end
    create_table :orders do |t|
      t.column "facebook_id", 'bigint', :null =>false
      t.string "key", :null =>false
      t.string "app_id", :null=>false
      t.datetime "created_date", :null => false
      t.string  "recipient_name"
      t.string  "address_identifier"
      t.string  "address_street"
      t.string  "address_subdistrict"                                    
      t.string  "address_district"                                    
      t.string  "address_province"                                    
      t.string  "address_postal_code"
      t.float "price", :null => false, :default =>0
       t.float "shipping_price", :null => false, :default =>0
      t.string  "status"
      t.string  "payment_type"
      t.string  "preview_image_url"
      t.string  "print_image_url"
      t.string  "signature_image_url"
      t.datetime "paid_time"
      t.datetime "print_time"
      t.datetime "ship_time"
   end
   
   create_table :confirm_transfers do |t|
      t.integer "order_id", :null=>false
      t.integer "transfer_to_bank_id", :null=>false
      t.string  "member_tel"
      t.string  "transfer_from_branch"
      t.datetime "transfer_date", :null => false
      t.float "transfer_price", :null => false, :default =>0
      t.datetime "created_date", :null => false
   end
   
   create_table :payment_issues do |t|
      t.integer "order_id", :null=>false
      t.text  "issue"
      
   end
    create_table :banks do |t|
      t.string  "bank_name", :null=>false
      t.string  "bank_branch", :null=>false
      t.string  "account_number", :null=>false
      t.string  "account_name", :null=>false
      t.string  "account_type", :null=>false
   end

   create_table :price_lists do |t|
      t.string   :paper_type, :null => false
      t.string   :print_type, :null => false
      t.string   :width, :null => false
      t.string   :height, :null => false
      t.float "price", :null => false, :default =>0
    end
    
    create_table :apps do |t|
      t.string   :name, :null => false
      t.string   :desc
      t.string   :image_url
    end
    
    create_table :traces do |t|
      t.string "facebook_id", :null => false
      t.text "params", :null => false
      t.string "ip_address", :null => false
      t.string "controller_name", :null => false
      t.string "action_name", :null => false
      t.string "result", :null => false
      t.datetime "accessed_date", :null => false
      t.string "browser"
      t.text "referer"
    end
   
    create_table :delayed_jobs, :force => true do |table|
      table.integer  :priority, :default => 0      # jobs can jump to the front of
      table.integer  :attempts, :default => 0      # retries, but still fail eventually
      table.text     :handler                      # YAML object dump
      table.text     :last_error                   # last failure
      table.datetime :run_at                       # schedule for later
      table.datetime :locked_at                    # set when client working this job
      table.datetime :failed_at                    # set when all retries have failed
      table.text     :locked_by                    # who is working on this object
      table.timestamps
    end
    create_table :error_logs, :force => true do |t|
      t.datetime "time",        :null => false
      t.string   "ip_address"
      t.string   "identifier",  :null => false
      t.text     "description", :null => false
    end
  end

  def self.down
    drop_table :error_logs
    drop_table :delayed_jobs
    drop_table :traces
    drop_table :apps
    drop_table :price_lists
    drop_table :friend_posters
    drop_table :banks
    drop_table :payment_issues
    drop_table :confirm_transfers
    drop_table :orders
    drop_table :members
  end
end
