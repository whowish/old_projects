class ReplyOfReplyAgreeableEntity < AgreeableEntity
  
  
  field :reply_of_reply_id, :type=>String
  
  def self.create_from(reply_of_reply)
    self.new(:reply_of_reply_id=>reply_of_reply.id, :content=>reply_of_reply.content.text)
  end

  def self.get_entity(reply_of_reply_id)
    ReplyOfReply.first(:conditions=>{:_id=>reply_of_reply_id})
  end

  def self.get_redundant_notification(reply_of_reply_id, notified_member_id, notification_class)
    
    notification_class.first(:conditions=>{"entity.reply_of_reply_id" => reply_of_reply_id,
                                           :notified_member_id => notified_member_id,
                                           :is_read => false
                                           })
                                           
  end

end