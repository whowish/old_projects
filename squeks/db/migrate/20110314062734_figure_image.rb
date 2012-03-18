class FigureImage < ActiveRecord::Migration
  def self.up
    create_table :figure_images do |t|
      t.integer  :figure_id
      t.string   :original_image_path
      t.integer  :ordered_number
    end
  end

  def self.down
    drop_table :figure_images
  end
end
