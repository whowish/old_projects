module NotificationHelper
  
  def calculate_latest_notification_data
    
    @notification_count = Notification.count(:conditions=>{:notified_member_id=>$member.id,:is_read=>false})
    @notifications = Notification.where(:notified_member_id=>$member.id).limit(5).desc(:created_date).entries
 
    @notification_label_count = "#{@notification_count}"
    @notification_label_count = "&#8734;" if @notification_count > 99
  
    @notification_last_id = 0
    @notification_last_id = @notifications[0].id if @notifications.length > 0
    
  end
  
end
