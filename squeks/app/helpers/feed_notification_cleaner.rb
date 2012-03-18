class FeedNotificationCleaner
  def perform
    Notification.delete_all(["created_date < ? AND is_read = ?",Time.now-86400*7,1])
    Feed.delete_all(["created_date < ?",Time.now-86400*2])
  end
end