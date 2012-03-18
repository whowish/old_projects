class MemberMailer < ActionMailer::Base
  
  
  
  # Resque
  #
  #
  #
  @queue = :normal

  def self.perform(method,*args)
    self.send(method,*args).deliver
  end

  layout "blank"

  # Tasks
  # 
  #
  #
  def notify_member_confirmation(email)   
    
    token = EmailRegistrationPending.first(:conditions=>{:email=>email})
    
    if !token
      token = EmailRegistrationPending.create(:email=>email)
      
      error = Mongoid.database.command({:getlasterror => 1})
      
      # There is a concurrent insertion occurs at the same time.
      if error['code'].to_i == 11000
        MongoidHelper.commit_database
        token = EmailRegistrationPending.first(:conditions=>{:email=>email})
      end
    end


    @url = "http://#{DOMAIN_NAME}/email_registration?email=#{email}&unique_key=#{token.id}"
    
    mail(:to => email,
         :from => "writePub <#{EMAIL}>",
         :subject => "You've registered. Please confirm your registration.",
         :content_type => "text/html"
         )

  end
  
  def notify_member_forget_password(member_id)   
    
    member = Member.first(:conditions=>{:_id=>member_id})   
    return if !member
 
    token = MemberForgetPassword.create(:member_id=>member.id,:created_date=>Time.now.utc)  

    @url = "http://#{DOMAIN_NAME}/member/recover_password_form?email=#{member.email}&unique_key=#{token.id}"
    @member = member
    
   mail(:to => member.email,
         :from => "WritePub <#{EMAIL}>",
         :subject => "Password Recovery",
         :content_type => "text/html"
         )
  end
end