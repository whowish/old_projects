class NotificationController < ApplicationController
  include NotificationHelper
  
  def index
    
  end
  
  def test
    Resque.enqueue(NotifyTest, Member.new(:username=>"asdasd"))
  end
  
  def check
    calculate_latest_notification_data()
    
    render :json=>{:ok=>true,:count=>@notification_count,:last_id=>@notification_last_id,:html=> (render_to_string :partial=>"notification/notification_open_panel")}
  end
  
  def read
    Notification.where(:notified_member_id=>$member.id).update_all(:is_read=>true)
    render :json=>{:ok=>true}
  end
end
