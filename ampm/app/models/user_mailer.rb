class UserMailer < ActionMailer::Base
  NOTIFY_CREATE = "NOTIFY_CREATE"
  NOTIFY_EDIT = "NOTIFY_EDIT"
  NOTIFY_CANCEL = "NOTIFY_CANCEL"
  NOTIFY_SETTLED_DATE = "NOTIFY_SETTLED_DATE"
  NOTIFY_CANCEL_SETTLED_DATE = "NOTIFY_CANCEL_SETTLED_DATE"
  NOTIFY_CREATOR_TO_SETTLE = "NOTIFY_CREATOR_TO_SETTLE"
  NOTIFY_COMMENT = "NOTIFY_COMMENT"
  
  def notify_create_event(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_create)
    sent_on Time.now 
  end
  
  def notify_edit_event(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_edit,:event_title=>@event.title)
    sent_on Time.now 
  end
  
  def notify_cancel_event(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_cancel_event,:event_title=>@event.title)
    sent_on Time.now 
  end
  
  def notify_settled_date(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_settled,:event_title=>@event.title)
    sent_on Time.now 
  end
  
  def notify_cancel_settled_date(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_cancel_settled,:event_title=>@event.title)
    sent_on Time.now 
  end
  
  def notify_creator_to_settle(event,creator)   
    @event = event
    @creator = creator
    @number_accepted = EventFriend.count(:conditions=>{:event_id => @event.id, :status=>EventFriend::STATUS_ACCEPTED})
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients  @creator.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_notify_settled,:event_title=>@event.title)
    sent_on Time.now 
  end
  
  def notify_comment(event,creator,receiver)   
    @event = event
    @creator = creator
    @receiver = receiver
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @receiver.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_notify_comment,:event_title=>@event.title,:commentor_name=>@creator.name)
    sent_on Time.now 
  end
  
  def notify_response(event,creator,responder,is_accepted)   
    @event = event
    @creator = creator
    @responder = responder
    @is_accepted = is_accepted
    @url = "http://apps.facebook.com/" + FACEBOOK_APP_NAME + "/event/view?event_id=" + @event.id.to_s
    recipients @creator.email
    content_type "text/html" 
    from "2Meet4 <whowish@gmail.com>" 
    subject word_for(:title_notify_response_accepted,:event_title=>@event.title,:responder_name=>@responder.name)
    subject word_for(:title_notify_response_rejected,:event_title=>@event.title,:responder_name=>@responder.name) if !is_accepted
    sent_on Time.now 
  end
  
end
