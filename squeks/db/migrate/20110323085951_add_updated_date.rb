class AddUpdatedDate < ActiveRecord::Migration
  def self.up
    add_column :members, :updated_date, :datetime
  end

  def self.down
    remove_column :members, :updated_date
  end
end
