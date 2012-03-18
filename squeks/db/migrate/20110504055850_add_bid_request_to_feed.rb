class AddBidRequestToFeed < ActiveRecord::Migration
  def self.up
        add_column :feeds,:bid_request_id,:integer
  end

  def self.down
    remove_column :feeds,:bid_request_id
  end
end
