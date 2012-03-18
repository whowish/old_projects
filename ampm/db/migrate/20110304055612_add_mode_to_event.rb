class AddModeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :mode, :string, :default=>"TIME"
  end

  def self.down
  end
end
