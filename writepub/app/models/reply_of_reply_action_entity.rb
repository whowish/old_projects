class ReplyOfReplyActionEntity < MemberActionEntity

  field :kratoo_id, :type=>String
  field :reply_of_reply_id, :type=>String
  
  def self.create_form(reply_of_reply_id)
    
    ror = ReplyOfReply.where(:_id=>reply_of_reply_id).entries.first
    raise MemberActionEntityNotExist, "ReplyOfReply(#{reply_of_reply_id}) does not exist." if !ror
    
    entity = ReplyOfReplyActionEntity.new(:reply_of_reply_id=>ror.id)
    entity.kratoo_id = ror.reply.kratoo_id
    entity.content = ror.content.text
    return entity
    
  end
  
  def self.get_previous_action(action_class,member_id,reply_of_reply_id)
    action_class.first(:conditions=>{:member_id=>member_id,"entity.reply_of_reply_id"=>reply_of_reply_id})
  end
  
end