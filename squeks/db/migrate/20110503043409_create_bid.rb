class CreateBid < ActiveRecord::Migration
  def self.up
    create_table :bid_requests, :force => true do |t|
      t.column   :facebook_id, 'bigint', :null => false
      t.integer  :figure_id, :null => false
      t.integer  :value
      t.string   :status
      t.datetime :created_date
    end

    add_column :figures, :value, :integer,:default=>1,:null=>false
    add_column :figures, :manager_facebook_id, 'bigint', :default=>0,:null=>false
    add_column :figures, :bid_start_time, :datetime
    add_column :figures, :bid_status, :string,:default=>"SETTLED",:null=>false
    
    ActiveRecord::Base.connection.execute("UPDATE `figures` SET `value`=1,`manager_facebook_id`=`creator_facebook_id`,`bid_status`='SETTLED'")

  end

  def self.down
     drop_table :bid_requests
  end
end
