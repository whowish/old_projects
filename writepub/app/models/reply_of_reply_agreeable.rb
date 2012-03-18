module ReplyOfReplyAgreeable

  def self.included(base)
    base.class_eval do
 
 
      include Agreeable
      alias_method :member_agree_without_notification,:member_agree
      
      def member_agree(member,agree_type)
        ok,previous_value = member_agree_without_notification(member,agree_type)
        
        if ok
          AgreeableNotification.enqueue_reply_of_reply(self.id, member.id, agree_type, previous_value)
        end
        
        return ok,previous_value
      end
      
      
    end
  end
end