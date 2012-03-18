class AddCollegeCountryCode < ActiveRecord::Migration
  def self.up
    add_column :colleges, :country_code, :string, :default=>"US"
  end

  def self.down
  end
end
