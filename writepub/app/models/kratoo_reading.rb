module KratooReading
  def update_score_read(identity)
    
    identity = $member.id if !$member.is_guest
    
    $redis.zremrangebyscore(redis_read_key,0,Time.now.to_i - 30*60)
    count = $redis.zadd(redis_read_key, Time.now.to_i, identity)

    Rails.logger.info { "count=#{count}" }
    
    if count == true # or count > 0; Redis <= 2.2.2 client turn a number into boolean
      self.inc(:views,1) 
      Resque.enqueue(ContextWord,$member.id,self.id,'read') if !$member.is_guest
    end
  end
  
  def update_score_reply
    Resque.enqueue(ContextWord,$member.id,self.id,'reply') if !$member.is_guest
  end
  
  def update_score_post
    Resque.enqueue(ContextWord,$member.id,self.id,'post') if !$member.is_guest
  end
  
  def redis_read_key
    "Kratoo:#{self.id}:read"
  end
  
  def is_read(identity)

    identity = $member.id if !$member.is_guest
    member_read = $redis.zscore(redis_read_key,identity)
    
    return member_read != nil
  end
end