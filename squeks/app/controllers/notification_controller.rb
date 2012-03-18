class NotificationController < ApplicationController
  include NotificationHelper
  
  def read
    Notification.update_all("is_read='1'","notified_facebook_id='#{$facebook.facebook_id}' AND id <= '#{params[:notification_id]}'")
    render :json=>{:ok=>true}
  end
  
  def check
    calculate_latest_notification_data()
    
    render :json=>{:ok=>true,:count=>@notification_count,:last_id=>@notification_last_id,:html=> (render_to_string :partial=>"notification/notification_open_panel")}
  end
  
end
