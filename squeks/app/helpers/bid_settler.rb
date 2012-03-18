class BidSettler
  def perform
    
      @figures = Figure.all(:limit=>10,:conditions=>["bid_status=:bid_status AND bid_start_time <= :time",{:bid_status=>Figure::BID_STATUS_BIDDING,:time=>(Time.now-86400)}])
      
      
      @figures.each { |figure|
      
        Lock.generate("bid_for",figure.id).synchronize {
          figure = Figure.first(:conditions=>{:id=>figure.id})
          
          next if figure.status == Figure::BID_STATUS_SETTLED
          
          bid = BidRequest.first(:conditions=>{:figure_id=>figure.id},:order=>"id DESC")
          
          if !bid
            figure.bid_status = Figure::BID_STATUS_SETTLED
            figure.save
            next
          end
          
          bid.status = BidRequest::STATUS_SETTLED
          bid.save
          
          figure.manager_facebook_id = bid.facebook_id
          figure.bid_status = Figure::BID_STATUS_SETTLED
          figure.save
          
          Feed.create_feed(bid)
          Notification.notify(bid)
          
          BidRequest.update_all("status='#{BidRequest::STATUS_FAILED_SETTLED}'",["status=? AND figure_id=?",BidRequest::STATUS_FAILED,figure.id])
        }
      }
    end
end