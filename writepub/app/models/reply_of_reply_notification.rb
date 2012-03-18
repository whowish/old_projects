class ReplyOfReplyNotification < Notification

  field :kratoo_id, :type=>String
  field :reply_id, :type=>String
  field :reply_of_reply_id, :type=>String
  embeds_many :names, :as => :notificator, :class_name => "Notificator"
  field :content, :type=>String
  
  index [
          [:kratoo_id, Mongo::DESCENDING],
          [:reply_id, Mongo::DESCENDING],
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::DESCENDING]
        ]
        
  index [
          [:reply_of_reply_id, Mongo::DESCENDING]
        ]
  
  
  # Resque for notification
  @queue = :notification
  
  def self.perform(reply_of_reply_id)
    
    # commit all changes, before doing anything
    MongoidHelper.commit_database
    
    Rails.logger.info { "Process ReplyOfReplyNotification reply_of_reply=#{reply_of_reply_id}" }
    
    r_o_r = ReplyOfReply.first(:conditions=>{:_id=>reply_of_reply_id})
    
    Rails.logger.info { "ReplyOfReply does not exists" } and return if !r_o_r
    
    reply = r_o_r.reply
    kratoo = reply.kratoo

    all_notified_member_ids = []
    all_notified_member_ids = [reply.post_owner.member_id] if reply.post_owner.is_member
    
    
    reply.replies.each { |reply_of_reply|
      break if r_o_r.id == reply_of_reply.id
      all_notified_member_ids.push(reply_of_reply.post_owner.member_id) if reply_of_reply.post_owner.is_member
    }
    
    all_notified_member_ids.uniq!
    
    all_notified_member_ids.each { |member_id| 

      # We don't notify the user who initiates this action
      if r_o_r.post_owner.is_member and member_id == r_o_r.post_owner.member_id
        next
      end
      
      Rails.logger.info { "Notify #{member_id}" }
    
      entity = ReplyOfReplyNotification.first(:conditions=>{:kratoo_id=>kratoo.id,
                                                            :reply_id=>reply.id,
                                                            :notified_member_id=>member_id,
                                                            :is_read=>false
                                                            })
      
      notificator = Notificator.build(r_o_r.post_owner)
      
      # Create new notification                                    
      if entity == nil
        
        entity = ReplyOfReplyNotification.new
        
        entity.notified_member_id = member_id
        entity.is_read = false
        entity.created_date = Time.now
        
        entity.kratoo_id = kratoo.id
        entity.reply_id = reply.id
        entity.reply_of_reply_id = r_o_r.id
        entity.names = [notificator]
        entity.content = reply.content.text
        
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
          elsif notificator.is_not_member and  other.is_not_member
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