module NotificationHelper
  def calculate_latest_notification_data
    @notification_count = Notification.count(:conditions=>{:notified_facebook_id=>$facebook.facebook_id,:is_read=>false})
    @notifications = Notification.all(:conditions=>{:notified_facebook_id=>$facebook.facebook_id,:is_read=>false},:order=>"created_date DESC",:limit=>5)
  
    if @notifications.length < 5
      @notifications += Notification.all(:conditions=>{:notified_facebook_id=>$facebook.facebook_id,:is_read=>true},:order=>"created_date DESC",:limit=>(5-@notifications.length))
    end
  
    @facebook_data_array = []
    @comment_data_array = []
    @figure_data_array = []
    @bid_request_data_array = []
  
    @notifications.each { |entity|
      @facebook_data_array.push(entity.facebook_id) if entity.facebook_id
      @comment_data_array.push(entity.comment_id) if entity.comment_id
      @figure_data_array.push(entity.figure_id) if entity.figure_id
      @bid_request_data_array.push(entity.bid_request_id) if entity.bid_request_id
    }
  
    @facebook_data = {}
    @comment_data = {}
    @figure_data = {}
    @bid_request_data = {}
  
    Member.all(:conditions=>{:facebook_id=>@facebook_data_array}).each { |entity|
      @facebook_data[entity.facebook_id] = entity
    }
  
    Comment.all(:conditions=>{:id=>@comment_data_array}).each { |entity|
      @comment_data[entity.id] = entity
    }
  
    Figure.all(:conditions=>{:id=>@figure_data_array}).each { |entity|
      @figure_data[entity.id] = entity
    }
  
    BidRequest.all(:conditions=>{:id=>@bid_request_data_array}).each { |entity|
      @bid_request_data[entity.id] = entity
    }
  
    @notification_label_count = "#{@notification_count}"
    @notification_label_count = "&#8734;" if @notification_count > 99
  
    @notification_last_id = 0
    @notification_last_id = @notifications[0].id if @notifications.length > 0
  end
end
