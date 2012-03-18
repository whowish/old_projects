# encoding: utf-8

module NotificationRspecHelper
  
  def mock_agree_notification(member,content,post_owner,entity)
    notification = AgreeableNotification.new
    notification.notified_member_id = member.id
    notification.is_read = false
    notification.created_date = Time.now
    notification.count = 1
    notification.content = content
    notification.names.push(Notificator.build(post_owner))
    notification.entity = entity
    notification.save 
    return notification
  end
  
  def mock_reply_notification(member,reply)
    notification = ReplyNotification.new
    notification.notified_member_id = member.id
    notification.is_read = false
    notification.created_date = Time.now
    notification.kratoo_id = reply.kratoo_id
    notification.reply_id = reply.id
    notification.content = reply.content.text
    notification.names.push(Notificator.build(reply.post_owner))
    notification.save
    return notification
  end
  
  def mock_ror_notification(member,ror)
    notification = ReplyOfReplyNotification.new
    notification.notified_member_id = member.id
    notification.is_read = false
    notification.created_date = Time.now
    notification.kratoo_id = ror.reply.kratoo_id
    notification.reply_id = ror.reply_id
    notification.reply_of_reply_id = ror.id
    notification.content = ror.content.text
    notification.names.push(Notificator.build(ror.post_owner))
    notification.save
    return notification
  end
end


