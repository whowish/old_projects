class AgreeableNotification < Notification
  
  field :count,:type=>Integer,:default=>0
  field :content, :type=>String
  embeds_many :names, :as => :notificator, :class_name => "Notificator"
  embeds_one :entity, :as => :entity, :class_name=>"AgreeableEntity"
  
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::ASCENDING],
          ["entity.kratoo_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::ASCENDING],
          ["entity.reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  index [
          [:notified_member_id, Mongo::DESCENDING],
          [:is_read, Mongo::ASCENDING],
          ["entity.reply_of_reply_id", Mongo::DESCENDING],
          ["_type", Mongo::DESCENDING]
        ]
        
  def self.enqueue_kratoo(entity_id, notifier_member_id, current_agree_type, previous_agree_type)
    
    agree_type_class = get_agree_type_class(current_agree_type, previous_agree_type)
    Resque.enqueue(agree_type_class, 
                      entity_id, 
                      notifier_member_id, 
                      KratooAgreeableEntity.name)
    
  end
  
  def self.enqueue_reply(entity_id, notifier_member_id, current_agree_type, previous_agree_type)
    
    agree_type_class = get_agree_type_class(current_agree_type, previous_agree_type)
    Resque.enqueue(agree_type_class, 
                      entity_id, 
                      notifier_member_id, 
                      ReplyAgreeableEntity.name)
    
  end

  def self.enqueue_reply_of_reply(entity_id, notifier_member_id, current_agree_type, previous_agree_type)
    
    agree_type_class = get_agree_type_class(current_agree_type, previous_agree_type)
    Resque.enqueue(agree_type_class, 
                      entity_id, 
                      notifier_member_id, 
                      ReplyOfReplyAgreeableEntity.name)
    
  end
  
  def self.get_agree_type_class(current_agree_type,previous_agree_type)
    
    case current_agree_type
      when Agreeable::AGREEABLE_TYPE_AGREE
        return AgreeNotification
      when Agreeable::AGREEABLE_TYPE_DISAGREE
        return DisagreeNotification
      else
        if previous_agree_type == Agreeable::AGREEABLE_TYPE_AGREE
          return UnagreeNotification
        elsif previous_agree_type == Agreeable::AGREEABLE_TYPE_DISAGREE
          return UndisagreeNotification
        else
          raise "Invalid current_agree_type(#{current_agree_type}) and previous_agree_type(#{previous_agree_type})"
        end
    end
    
  end

  def self.perform(entity_id, notifier_member_id, agreeable_entity_class_name)
  
    MongoidHelper.commit_database
   
    Rails.logger.info { "------------------------------" }
    Rails.logger.info { "Process #{self.name} + #{agreeable_entity_class_name}" }
    
    agreeable_entity_class = Object::const_get(agreeable_entity_class_name)
    
    entity = agreeable_entity_class.get_entity(entity_id)
    agreeable_entity = agreeable_entity_class.create_from(entity)
    
    raise AgreeableNotificationException, "There is no entity. (Maybe deleted)" if entity == nil
    raise AgreeableNotificationException, "Owner is not a member." if !entity.post_owner.is_member
    raise AgreeableNotificationException, "Owner is the modifier." if entity.post_owner.member_id == notifier_member_id

    notifier = Member.first(:conditions=>{:_id=>notifier_member_id})
    raise AgreeableNotificationException, "Member does not exist. #{notifier_member_id}" if !notifier

    is_cancel = self.cancel_previous_action(entity, 
                                            notifier, 
                                            entity.post_owner.member_id, 
                                            agreeable_entity)
    
    if is_cancel == false or [AgreeNotification,DisagreeNotification].include?(self)
        
      self.add_action(entity, 
                      notifier, 
                      entity.post_owner.member_id, 
                      agreeable_entity)

    end
    
  rescue AgreeableNotificationException=>e
    Rails.logger{"\t#{e.message}"}
  end
  
  
  def self.cancel_previous_action(entity, notifier, post_owner_member_id, agreeable_entity)
    
    is_cancel = false
    
    other_classes = [AgreeNotification,DisagreeNotification,UnagreeNotification,UndisagreeNotification]
    other_classes.delete(self)
    
    other_classes.each { |klass|
      previous_notification = agreeable_entity.class.get_redundant_notification(entity.id, post_owner_member_id, klass)
      is_cancel = is_cancel || previous_notification.remove_notifier(notifier) if previous_notification
    }
    
    return is_cancel
  end
  
  def remove_notifier(notifier)
    num_deleted = 0
    self.names.where(:member_id=>notifier.id).each { |name|
      name.destroy
      num_deleted += 1
    }
    
    self.count = self.count - num_deleted
    
    if self.count == 0
      self.destroy
    else
      self.save
    end
    
    return (num_deleted > 0)
  end
  
  
  def self.add_action(entity, notifier, post_owner_member_id, agreeable_entity)
    
    previous_notification = agreeable_entity.class.get_redundant_notification(entity.id, post_owner_member_id, self)
    
    if !previous_notification
      previous_notification = self.new
      previous_notification.entity = agreeable_entity
      previous_notification.notified_member_id = post_owner_member_id
    end
    
    previous_notification.add_notifier(notifier)
    previous_notification.is_read = false
    previous_notification.created_date = Time.now
    previous_notification.save
  
  end

  def add_notifier(notifier)
    notifier = PublicMemberNotificator.new({:member_id=>notifier.id,:username=>notifier.username}) 
    self.names.push(notifier)
    self.count += 1
  end

end
