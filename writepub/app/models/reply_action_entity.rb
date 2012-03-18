class ReplyActionEntity < MemberActionEntity
 
  field :kratoo_id, :type=>String
  field :reply_id, :type=>String
  
  def self.create_form(reply_id)
    
    reply = Reply.where(:_id=>reply_id).entries.first
    raise MemberActionEntityNotExist, "Reply(#{reply_id}) does not exist." if !reply

    entity = ReplyActionEntity.new(:reply_id=>reply.id)
    entity.kratoo_id = reply.kratoo_id
    entity.content = reply.content.text
    return entity
    
  end

  def self.get_previous_action(action_class,member_id,reply_id)
    action_class.first(:conditions=>{:member_id=>member_id,"entity.reply_id"=>reply_id})
  end

end