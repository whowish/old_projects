class AgreeMemberAction < MemberAction
    
  @queue = :member_action
  
  def self.perform(entity_class_name, related_entity_id, member_id)
    
    Rails.logger.info{" Perform MemberAction #{self} #{entity_class_name} #{related_entity_id} #{member_id}"}
    MongoidHelper.commit_database
    
    cancel_action(DisagreeMemberAction, entity_class_name, related_entity_id, member_id)
    add_action(AgreeMemberAction, entity_class_name, related_entity_id, member_id)
    
  rescue MemberActionEntityNotExist=>e
    Rails.logger.info{e.message}
  end
  
end