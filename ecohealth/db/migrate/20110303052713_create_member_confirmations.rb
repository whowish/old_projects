class CreateMemberConfirmations < ActiveRecord::Migration
  def self.up
    create_table :member_confirmations do |t|
      t.string "unique_key", :null => false
      t.integer "member_id", :null => false
    end
    
  end

  def self.down
    drop_table :member_confirmations
  end
end
