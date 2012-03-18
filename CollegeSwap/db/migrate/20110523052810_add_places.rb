class AddPlaces < ActiveRecord::Migration
  def self.up
      add_column :colleges, :place_name, :string
      add_column :colleges, :place_address, :text
  end

  def self.down
  end
end
