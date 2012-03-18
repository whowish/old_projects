class CommentPendingAndFigureLovePending < ActiveRecord::Migration
  def self.up
    create_table :comment_pendings do |t|
      t.string :status
      t.text :data
      t.string :unique_key
    end
    
    create_table :figure_love_pendings do |t|
      t.string :status
      t.text :data
      t.string :unique_key
    end

  end

  def self.down
    drop_table :comment_pendings
    drop_table :figure_love_pendings
  end
end
