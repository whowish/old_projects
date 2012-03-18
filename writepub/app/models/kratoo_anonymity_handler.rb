module KratooAnonymityHandler

  def set_anonymous_name(member,name)
    
    new_name = name
    runner = 0
    while true
      ok = $redis.sadd(redis_anonymous_names(), new_name)
      
      break if ok
      
      runner += 1
      new_name = "#{name}-#{runner}"
    end
    
    $redis.set(redis_anonymous_name_key(member), new_name)
    
    if runner > 0
      self.post_owner.username = new_name
      self.save
    end

  end


  def get_anonymous_name(member)
    
    name = $redis.get(redis_anonymous_name_key(member))
    return (name || "")
    
  end
  
  
  def is_anonymous_name_used(name)
    return $redis.sismember(redis_anonymous_names(), name)
  end
  
  
  def get_post_owner_type(member)
    
    type = $redis.get(redis_kratoo_members_key(member)) 
    return (type || "")
    
  end
  
  def set_post_owner_type(member,type)
    $redis.set(redis_kratoo_members_key(member), type)
  end



  def redis_anonymous_name_key(member)
    "Kratoo:#{self.id}:Member:#{member.id}:anonymous_name"
  end
  
  def redis_anonymous_names()
    "Kratoo:#{self.id}:anonymous_names"
  end
  
  def redis_kratoo_members_key(member)
    "Kratoo:#{self.id}:Member:#{member.id}:member_type"
  end

end