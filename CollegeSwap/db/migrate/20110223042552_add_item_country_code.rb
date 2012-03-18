class AddItemCountryCode < ActiveRecord::Migration
  def self.up
    add_column :items, :country_code, :string, :default=>"US"
  end

  def self.down
  end
end
