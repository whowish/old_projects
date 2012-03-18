class CreateDiscussionHourStat < ActiveRecord::Migration
  def self.up
    create_table :discussion_hour_counts,{:id=>false} do |t|
      t.string :guid
      t.date :date
      t.integer :hour
      t.integer :discussion_id
      t.integer :loves
      t.integer :hates
    end
    
    execute "ALTER TABLE discussion_hour_counts ADD PRIMARY KEY (guid);"

    
  end

  def self.down
    drop_table :discussion_hour_counts
  end
end
