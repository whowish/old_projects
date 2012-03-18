class CreateForgetPassword < ActiveRecord::Migration
 def self.up
    create_table :member_forget_passwords do |t|
      t.string "unique_key", :null => false
      t.integer "member_id", :null => false
      t.datetime "created_date", :null => false
    end
    
  end

  def self.down
    drop_table :member_forget_passwords
  end
end
