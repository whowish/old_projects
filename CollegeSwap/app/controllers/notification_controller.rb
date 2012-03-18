class NotificationController < ApplicationController
  def read
    Notification.update_all({:is_read=>1},["notified_facebook_id =? AND is_read=0", $facebook.facebook_id])

    render :json=>{:ok=>true}
  end
end
