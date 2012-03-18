class CreateDiscussionPending < ActiveRecord::Migration
  def self.up
    create_table :discussion_pendings do |t|
      t.string :status
      t.text :data
      t.string :unique_key
    end
    
    remove_column :discussion_figures, :discussion_side
  end

  def self.down
    drop_table :discussion_pendings
  end
end
