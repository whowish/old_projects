class FigureCountry < ActiveRecord::Migration
  def self.up
    add_column :figures, :creator_facebook_id, 'bigint'
    add_column :figures, :country_code, :string
  end

  def self.down
    remove_column :figures, :creator_facebook_id
    remove_column :figures, :country_code
  end
end
