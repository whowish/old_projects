class MemberCountry < ActiveRecord::Migration
  def self.up
    add_column :members, :country_code, :string
  end

  def self.down
    remove_column :members, :country_code
  end
end
