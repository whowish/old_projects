class MemberAction
  include Mongoid::Document
  
  
  field :member_id, :type=>String
  field :created_date, :type=>DateTime
  embeds_one :entity, :as => :entity, :class_name=>"MemberActionEntity"
  
  
  index [
          [:member_id, Mongo::DESCENDING],
          [:created_date, Mongo::DESCENDING]
        ]
  
  index [
          [:member_id, Mongo::DESCENDING],
          ["entity.kratoo_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          [:member_id, Mongo::DESCENDING],
          ["entity.reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          [:member_id, Mongo::DESCENDING],
          ["entity.reply_of_reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          ["entity.kratoo_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          ["entity.reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          ["entity.reply_of_reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
  
  
  def self.post(entity,member_id)

    Resque.enqueue(PostMemberAction, 
                    get_entity_class(entity).name,
                    entity.id,
                    member_id)

  end
  
  
  def self.cancel_post(entity,member_id)
  
    Resque.enqueue(CancelPostMemberAction, 
                    get_entity_class(entity).name,
                    entity.id,
                    member_id)
  
  end
  
  
  def self.agree(entity,member_id)
    
    Resque.enqueue(AgreeMemberAction, 
                      get_entity_class(entity).name,
                      entity.id,
                      member_id)
    
  end
  
  
  def self.unagree(entity,member_id)
    
    Resque.enqueue(UnagreeMemberAction, 
                      get_entity_class(entity).name,
                      entity.id,
                      member_id)
    
  end
  
  
  def self.disagree(entity,member_id)
  
      Resque.enqueue(DisagreeMemberAction, 
                        get_entity_class(entity).name, 
                        entity.id,
                        member_id)
  
  end
  
  
  def self.undisagree(entity,member_id)
    
    self.unagree(entity,member_id)
                      
  end
  
  
  def self.get_entity_class(entity)
    
    if entity.instance_of?(Kratoo)
      
      return KratooActionEntity
      
    elsif entity.instance_of?(Reply)
      
      return ReplyActionEntity
      
    elsif entity.instance_of?(ReplyOfReply)
      
      return ReplyOfReplyActionEntity
      
    else
      raise 'Unsupported entity type (#{entity.class.name})'
    end
    
  end


  def self.cancel_action(action_class, entity_class_name, related_entity_id, member_id)
    
    entity_class = Object::const_get(entity_class_name)
    
    action = entity_class.get_previous_action(action_class, member_id, related_entity_id)
    action.destroy if action
    
  end
  
  
  def self.add_action(action_class, entity_class_name, related_entity_id, member_id)
    
    entity_class = Object::const_get(entity_class_name)
    
    action = entity_class.get_previous_action(action_class, member_id, related_entity_id)
    return if action
    
    entity = entity_class.create_form(related_entity_id)
    
    action = action_class.new
    action.member_id = member_id
    action.created_date = Time.now
    action.entity = entity
    action.save
    
  end
end








