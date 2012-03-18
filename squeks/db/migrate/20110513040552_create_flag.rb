class CreateFlag < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
      t.integer :figure_id
      t.integer :comment_id
      t.column "facebook_id", 'bigint', :null =>false
      t.datetime :created_date
      t.string :flag_type
      t.text :reason
    end

  end

  def self.down
    drop_table :flags
  end
end
