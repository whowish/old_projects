class Notification < ActiveRecord::Base
  
  ACTION_AGREE = "AGREE"
  ACTION_REPLY = "REPLY"
  ACTION_BID = "BID"
  ACTION_WIN_BID = "WIN_BID"
  
  class << self
    
    def notify(entity)
      case true
        when entity.instance_of?(Comment) then notify_comment(entity)
        #when entity.instance_of?(CommentAgree) then notify_comment_agree(entity)
        when entity.instance_of?(BidRequest) then notify_bid(entity)
      end
      
      Delayed::Job.enqueue FeedNotificationCleaner.new if rand(1000) == 1
    end
    
    private
    def notify_bid(entity)

      if entity.status == BidRequest::STATUS_SUCCESSFUL
        notify_make_bid(entity)
      elsif entity.status == BidRequest::STATUS_SETTLED
        notify_win_bid(entity)
      end
      
    end
    
    private
    def notify_win_bid(entity)
      Notification.create(:notified_facebook_id=>entity.facebook_id,
                            :facebook_id=>entity.facebook_id,
                            :bid_request_id=>entity.id,
                            :figure_id=>entity.figure_id,
                            :is_anonymous=>0,
                            :action=>Notification::ACTION_WIN_BID,
                            :data=>""
                            )
    end
    
    private
    def notify_make_bid(entity)
      second_bid = BidRequest.first(:conditions=>["id < ? AND figure_id=?",entity.id,entity.figure_id],:order=>"id DESC")
      figure = Figure.first(:conditions=>{:id=>entity.figure_id})
      
      if second_bid == nil # notify manager
          
         return if figure.manager_facebook_id == 0 or figure.manager_facebook_id == nil
         return if figure.manager_facebook_id == entity.facebook_id
          
         Notification.create(:notified_facebook_id=>figure.manager_facebook_id,
                            :facebook_id=>entity.facebook_id,
                            :bid_request_id=>entity.id,
                            :figure_id=>entity.figure_id,
                            :is_anonymous=>0,
                            :action=>Notification::ACTION_BID,
                            :data=>""
                            )
                            
      else # notify second bidder
      
        return if second_bid.facebook_id == entity.facebook_id
      
        Notification.create(:notified_facebook_id=>second_bid.facebook_id,
                            :facebook_id=>entity.facebook_id,
                            :bid_request_id=>entity.id,
                            :figure_id=>entity.figure_id,
                            :is_anonymous=>0,
                            :action=>Notification::ACTION_BID,
                            :data=>""
                            )
        
      end
    end
    
    private
    def notify_comment(entity)
      return if entity.parent_id == 0
      
      comments = Comment.all(:select=>"DISTINCT(facebook_id)",:conditions=>["id=? OR parent_id=?",entity.parent_id,entity.parent_id])
      
      comments.each { |comment|
        next if comment.facebook_id == entity.facebook_id
        
        Notification.create(:notified_facebook_id=>comment.facebook_id,
                            :facebook_id=>entity.facebook_id,
                            :comment_id=>entity.id,
                            :figure_id=>entity.figure_id,
                            :is_anonymous=>entity.is_anonymous,
                            :action=>Notification::ACTION_REPLY,
                            :data=>""
                            )
      } 
    end
    
    def notify_comment_agree(entity)
      comment = Comment.first(:conditions=>{:id=>entity.comment_id})
      
      return if !comment
      return if comment.facebook_id == entity.facebook_id
      
      Notification.create(:notified_facebook_id=>comment.facebook_id,
                            :facebook_id=>entity.facebook_id,
                            :comment_id=>entity.comment_id,
                            :figure_id=>comment.figure_id,
                            :is_anonymous=>entity.is_anonymous,
                            :action=>Notification::ACTION_AGREE,
                            :data=>entity.agree_type
                            )
    end
    
  end
  
  before_create :update_time
  
  def update_time
    self.created_date = Time.now
  end
end