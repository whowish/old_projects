class MemberMailer < ActionMailer::Base

  def notify_member_confirmation(member)   
    
    token = MemberConfirmation.first(:conditions=>{:member_id=>member.id})
    
    if !token
      token = MemberConfirmation.create(:member_id=>member.id)
    end

    @url = "http://"+DOMAIN_NAME+"/member/confirm_email?email="+member.email+"&unique_key="+token.unique_key
    @member = member
    
    recipients member.email
    content_type "text/html" 
    from "EcoHealth <"+EMAIL+">" 
    subject "You've registered with EcoHealth. Please confirm your registration."
    sent_on Time.now 
  end
  
  def notify_member_forget_password(member)   
    
    token = MemberForgetPassword.create(:member_id=>member.id,:created_date=>Time.now.utc)

    @url = "http://"+DOMAIN_NAME+"/member/recover_password_form?email="+member.email+"&unique_key="+token.unique_key
    @member = member
    
    recipients member.email
    content_type "text/html" 
    from "EcoHealth <"+EMAIL+">" 
    subject "Password Recovery"
    sent_on Time.now 
  end
end
