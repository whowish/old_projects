class UserMailer < ActionMailer::Base
  def contact_us(facebook_name,user_mail,topic,content)
    @from_facebook_name = facebook_name
    @from_mail = user_mail
    @topic = topic
    @content = content
    recipients "service@whowish.com"
    content_type "text/html" 
    from user_mail 
    subject "FriendMage Help: " + topic
    sent_on Time.now 
  end
end
