class ChangeItemIdFromItemImage < ActiveRecord::Migration
  def self.up
    change_column :item_images, :item_id, :integer
  end

  def self.down
  end
end
