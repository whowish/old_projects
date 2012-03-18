class AddImageToPartnership < ActiveRecord::Migration
  def self.up
    add_column :partners, :original_image_path, :string
  end

  def self.down
    remove_column :partners, :original_image_path
  end
end
