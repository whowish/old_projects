class ChangeBidStatus < ActiveRecord::Migration
  def self.up
    BidRequest.update_all("status='#{BidRequest::STATUS_FAILED_SETTLED}'",["status=?",BidRequest::STATUS_FAILED])
  end

  def self.down
  end
end
