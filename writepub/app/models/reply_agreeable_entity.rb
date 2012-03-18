class ReplyAgreeableEntity < AgreeableEntity
  
  
  field :reply_id, :type=>String
  
  def self.create_from(reply)
    self.new(:reply_id=>reply.id, :content=>reply.content.text)
  end

  def self.get_entity(reply_id)
    Reply.first(:conditions=>{:_id=>reply_id})
  end
  
  def self.get_redundant_notification(reply_id, notified_member_id, notification_class)
    
    notification_class.first(:conditions=>{"entity.reply_id" => reply_id,
                                           :notified_member_id => notified_member_id,
                                           :is_read => false
                                           })
                                           
  end
  
  
end