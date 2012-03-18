module ReplyCount
  def update_running_number()
    count = $redis.incr(redis_reply_running_number)
    return count
  end
  
  def redis_reply_running_number
    "Kratoo:#{self.id}:running_number"
  end

end