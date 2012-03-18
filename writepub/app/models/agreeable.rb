module Agreeable 
  
  # Assume that a model has :id, :agrees, and :disagrees
  # :id is the unique id that identifies the model
  # :agrees is the number of agrees
  # :disagees is the number of disagrees
  # 
  # When a post is agreed, its owner should gain a point.
  # Therefore, we assume that there is a class Member with the integer field :fame
  #
  # Here is how we organize the data
  # - A key "agreeable_key", which hold AGREE, DISAGREE, or nil in order to specify the action.
  # - A set "agree_set_key", which holds ids of which member agree to this post.
  # - A set "disagree_set_key", which holds ids of which member disagree to this post.
  #
  
  def self.included(base)
    base.class_eval do
      
      field :agrees, :type=>Integer, :default=>0
      field :disagrees, :type=>Integer, :default=>0
      
    end
  end

  AGREEABLE_TYPE_AGREE = "AGREE"
  AGREEABLE_TYPE_DISAGREE = "DISAGREE"
  
  def member_agree(member,agree_type)
    return if member.is_guest
    
    case agree_type
      when AGREEABLE_TYPE_AGREE
        return self.agree(member.id)
      when AGREEABLE_TYPE_DISAGREE
        return self.disagree(member.id)
      else
        return self.unagree(member.id)
    end
    
    
    
  end
  
  def get_agree_user(agree_type)
    case agree_type
      when AGREEABLE_TYPE_AGREE
        return $redis.zrange(agree_set_key,0,-1)
      when AGREEABLE_TYPE_DISAGREE
        return $redis.zrange(disagree_set_key,0,-1)
      else
        return []
    end
    
  end
  
  def agree(member_id)

    previous_value = $redis.getset(agreeable_key(member_id),AGREEABLE_TYPE_AGREE)
    
    owner = nil
    
    if self.post_owner.is_member
      owner = Member.first(:conditions=>{:_id=>self.post_owner.member_id})
    end
    
    action = false

    case previous_value
      when AGREEABLE_TYPE_AGREE
        # do nothing
      when AGREEABLE_TYPE_DISAGREE
        
        self.inc(:agrees,1)
        self.inc(:disagrees,-1)
        
        owner.inc(:fame,1) if owner
        
        $redis.zadd(agree_set_key, -Time.now.to_f, member_id)
        $redis.zrem(disagree_set_key, member_id)
        
        action = true
        
      else
        
        self.inc(:agrees,1)
        
        owner.inc(:fame,1) if owner
        
        $redis.zadd(agree_set_key, -Time.now.to_f, member_id)
        
        action = true
        
    end
      
    MemberAction.agree(self,member_id)

    return action,previous_value
  end
  
  def disagree(member_id)
    
    previous_value = $redis.getset(agreeable_key(member_id),AGREEABLE_TYPE_DISAGREE)
    
    owner = nil
    
    if self.post_owner.is_member
      owner = Member.first(:conditions=>{:_id=>self.post_owner.member_id})
    end
    
    action = false
    case previous_value
      when AGREEABLE_TYPE_AGREE
        
        self.inc(:disagrees,1)
        self.inc(:agrees,-1)
        owner.inc(:fame,-1) if owner
        
        $redis.zadd(disagree_set_key, -Time.now.to_f, member_id)
        $redis.zrem(agree_set_key, member_id)
        
        action = true
        
      when AGREEABLE_TYPE_DISAGREE
        # do nothing
      else
        
        self.inc(:disagrees,1)
        
        $redis.zadd(disagree_set_key, -Time.now.to_f, member_id)
        
        action = true
        
      end
    
    MemberAction.disagree(self,member_id)
    
    return action,previous_value
  end
  
  def unagree(member_id)
    previous_value = $redis.getset(agreeable_key(member_id),"")
    
    owner = nil
    
    if self.post_owner.is_member
      owner = Member.first(:conditions=>{:_id=>self.post_owner.member_id})
    end
    
    action = false
    case previous_value
      when AGREEABLE_TYPE_AGREE
        
        self.inc(:agrees,-1)
        
        owner.inc(:fame,-1) if owner
        
        $redis.zrem(agree_set_key, member_id)
        
        action = true
        
      when AGREEABLE_TYPE_DISAGREE
        
        self.inc(:disagrees,-1)
        
        $redis.zrem(disagree_set_key, member_id)
        
        action = true
        
      else
        # do nothing
      end
    
    MemberAction.unagree(self,member_id)
    
    return action,previous_value
  end
  
  def is_agree_or_disagree(member_id)
    
    agree_type = $redis.get(agreeable_key(member_id))
    
    return (agree_type || "")
  end
  
  private
    def agreeable_key(member_id)
      "#{self.class.name}:#{self.id}:Member:#{member_id}"
    end
  
    def agree_set_key
      "#{self.class.name}:#{self.id}:#{AGREEABLE_TYPE_AGREE}"
    end
    
    def disagree_set_key
      "#{self.class.name}:#{self.id}:#{AGREEABLE_TYPE_DISAGREE}"
    end
  
end