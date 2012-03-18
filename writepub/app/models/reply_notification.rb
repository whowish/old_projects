class ReplyNotification < Notification

  # Field definitions
  #
  #
  #
  field :kratoo_id, :type=>String
  field :reply_id, :type=>String
  embeds_many :names, :as => :notificator, :class_name=>"Notificator"
  field :content, :type=>String
  
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::ASCENDING],
          [:kratoo_id, Mongo::DESCENDING]
        ]
        
   index [
          [:reply_id, Mongo::DESCENDING]
        ]
          
  
  # Resque for notification
  #
  #
  #
  @queue = :notification
  
  def self.perform(reply_id)
   
    MongoidHelper.commit_database
    
    Rails.logger.info { "Process ReplyNotification reply=#{reply_id}" }
    
    reply = Reply.first(:conditions=>{:_id=>reply_id})
    
    Rails.logger.info { "Reply does not exists" } and return if !reply
    
    kratoo = reply.kratoo
    
    Rails.logger.info { "Kratoo does not exists" } and return if !kratoo
    
    all_notified_member_ids = []
    all_notified_member_ids = [kratoo.post_owner.member_id] if kratoo.post_owner.is_member
    
    kratoo.replies.each { |r|
      all_notified_member_ids.push(r.post_owner.member_id) if r.post_owner.is_member
    }
    
    all_notified_member_ids.uniq!
    
    all_notified_member_ids.each { |member_id| 

      # We don't notify the user who initiates this action
      if reply.post_owner.is_member and member_id == reply.post_owner.member_id
        next
      end
      
      Rails.logger.info { "Notify #{member_id}" }
    
      entity = ReplyNotification.first(:conditions=>{:kratoo_id=>kratoo.id,
                                            :notified_member_id=>member_id,
                                            :is_read=>false
                                            })
      
      notificator = Notificator.build(reply.post_owner)   
        
      # Create new notification                                    
      if entity == nil
        
        entity = ReplyNotification.new
        
        entity.notified_member_id = member_id
        entity.is_read = false
        entity.created_date = Time.now
        
        entity.kratoo_id = kratoo.id
        entity.reply_id = reply_id
        entity.names = [notificator]
        entity.content = kratoo.title
        
        entity.save
  
      else
        
        entity.created_date = Time.now
        entity.is_read = false
        
        already_in = false
        entity.names.each { |other|
          if notificator.is_member and  other.is_member
            if other.member_id == notificator.member_id.to_s
              already_in = true
              break
            end
          elsif !notificator.is_not_member and !other.is_not_member
            if other.username == notificator.username
              already_in = true
              break
            end
          end
        }
        
        Rails.logger.info { "Notificator already in the reply  list" } and return if already_in
        
        entity.names.push(notificator)
        
        entity.save
      end    
    }
    
  end
  
end