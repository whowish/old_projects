class CreateMember < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string "email", :null => false
      t.string "password"
      t.string "name", :null => false
      t.string "status", :null => false
      t.integer "is_admin", :null => false
      t.datetime "created_date", :null => false
    end
    
  end

  def self.down
    drop_table :members
  end
end
