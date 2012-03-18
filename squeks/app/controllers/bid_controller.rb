class BidController < ApplicationController
  
  def index
    
  end
  
  def settle
  
    Delayed::Job.enqueue BidSettler.new
    
    render :text=>"OK"
  end
  
  def make
    
    if $facebook.is_guest
      render :json=>{:ok=>false, :error_message=>MUST_LOGIN_ERROR}
      return
    end
    
    Lock.generate("bid_for",params[:figure_id]).synchronize {
    
      Lock.generate("bidder_",$facebook.facebook_id).synchronize {
        figure = Figure.first(:conditions=>{:id=>params[:figure_id]})
        bidder = $facebook

        if params[:value].to_i <= figure.value
          render :json=>{:ok=>false, :error_message=>"You have to pay at least #{figure.value+1}"}
          return
        end
      
        if bidder.credits < params[:value].to_i
          render :json=>{:ok=>false, :error_message=>"You cannot bid this because you don't have enough credits."}
          return
        end
        
#        if figure.manager_facebook_id == $facebook.facebook_id and figure.bid_status == Figure::BID_STATUS_SETTLED
#          render :json=>{:ok=>false, :error_message=>"You cannot bid this because you are currently a manager."}
#          return
#        end
        
        latest_bid = BidRequest.first(:conditions=>{:figure_id=>params[:figure_id],:status=>BidRequest::STATUS_SUCCESSFUL})
        if latest_bid
          latest_bidder = Member.first(:conditions=>{:facebook_id=>latest_bid.facebook_id})
#          if latest_bid.facebook_id == $facebook.facebook_id
#            render :json=>{:ok=>false, :error_message=>"You cannot bid this because you are currently the highest bidder."}
#            return
#          end
        end 
        
        
        
        bid_request = BidRequest.new()
        bid_request.facebook_id = $facebook.facebook_id
        bid_request.figure_id = params[:figure_id]
        bid_request.value = params[:value]
        bid_request.status = BidRequest::STATUS_SUCCESSFUL
        bid_request.created_date = Time.now
        bid_request.save
          
        bidder.add_credit(-params[:value].to_i)
      
        
        if latest_bidder 
          latest_bidder.add_credit(latest_bid.value)
    
        end 
        
        if latest_bid 
          latest_bid.status = BidRequest::STATUS_FAILED
          latest_bid.save
        else
          figure.bid_start_time = Time.now
        end
        
        figure.value = params[:value]
        figure.bid_status = Figure::BID_STATUS_BIDDING
        figure.save
        Notification.notify(bid_request)
        Feed.create_feed(bid_request)
        
        render :json => {:ok=>true,:credits=>bidder.credits,:previous_credits=>bidder[:previous_credits],:value=>figure.value,:html=>(render_to_string :partial=>"bid/bid_successfully",:locals=>{:figure=>figure})}
      }
    }
  end
end
