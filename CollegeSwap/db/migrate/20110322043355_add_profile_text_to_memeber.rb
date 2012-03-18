class AddProfileTextToMemeber < ActiveRecord::Migration
  def self.up
    add_column :members, :profile_text, :text
  end

  def self.down
    
  end
end
