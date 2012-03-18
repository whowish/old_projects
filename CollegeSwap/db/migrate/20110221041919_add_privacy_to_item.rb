class AddPrivacyToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :privacy, :string, :default=>"ALL"
  end

  def self.down
  end
end
