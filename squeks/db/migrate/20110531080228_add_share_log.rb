class AddShareLog < ActiveRecord::Migration
  def self.up
    create_table :share_logs do |t|
      t.string :share_type
      t.column :facebook_id, 'bigint'
      t.datetime :created_date
    end
  end

  def self.down
    drop_table :share_logs
  end
end
