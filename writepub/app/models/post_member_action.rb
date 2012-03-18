class PostMemberAction < MemberAction
  
  @queue = :member_action
  
  # Arguments's explanation
  # - action_class can be PostMemberAction, AgreeMemberAction, or DisagreeMemberAction
  # - entity_class can be KratooActionEntity, ReplyActionEntity, or ReplyOfReplyActionEntity
  # - related_entity_id can be kratoo_id, reply_id, or reply_of_reply_id
  # 
  def self.perform(entity_class_name, related_entity_id, member_id)
    
    Rails.logger.info{" Perform MemberAction #{self} #{entity_class_name} #{related_entity_id} #{member_id}"}
    MongoidHelper.commit_database
    
    add_action(self, entity_class_name, related_entity_id, member_id)
    
  rescue MemberActionEntityNotExist=>e
    Rails.logger.info{e.message}
  end
  
end
