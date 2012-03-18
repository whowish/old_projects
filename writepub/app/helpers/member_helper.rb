module MemberHelper
  
  def process_login(username,password,remember_me,force=false)

    member = Member.first(:conditions=>{:username_downcase=>username.downcase})
    
    raise word_for(:login,:invalid) if !member

    raise word_for(:login,:invalid) if !member.is_password_valid(password) and !force

    set_member(member,remember_me)
    
    return true
  rescue Exception=>e
    return false,{:summary=>e.message}
  end
  
  def set_member(member,remember_me=false)
    member.save_cookies(session,cookies,remember_me=="yes")
    
    $member = member
  end
  
  def process_register(username,password,email,facebook_id,is_verified)
    
    errors = MemberValidator.validate({:username=>username,
                                       :password=>password})
                                       
    if errors.length > 0
      return false,nil,errors
    end
    
    member = Member.new
    member.username = params[:username]
    member.password = Member.encrypt_password(params[:password])
    member.profile_picture_path = ""
    member.email = email
    member.facebook_id = facebook_id
    member.is_admin = false
    member.created_date = Time.now
    member.is_verified = is_verified
    
    member.save
    
    errors.merge!(MemberValidator.validate_uniqueness)
    
    if errors.length > 0
      return false,nil,errors
    end
    
    return true,member,{}
    
  end
  
end
