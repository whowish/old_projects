class CreateImageLike < ActiveRecord::Migration
  def self.up
    create_table :figure_image_likes do |t|
      t.integer  :figure_image_id
      t.column   :facebook_id, 'bigint', :null => false
      t.string   :like_type
      t.datetime :created_date
      t.boolean  :is_anonymous, :null => false, :default => false
    end
    add_column :figure_images, :likes, :integer,:null => false, :default => 0
    add_column :figure_images, :dislikes, :integer,:null => false, :default => 0
  end

  def self.down
    remove_column :figure_images, :dislikes
    remove_column :figure_images, :likes
    drop_table :figure_image_likes
  end
end
