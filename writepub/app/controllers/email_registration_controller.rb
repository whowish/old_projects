class EmailRegistrationController < ApplicationController
  include MemberHelper
  
  def index
    
    params[:email].downcase!
    
    existed_member = Member.first(:conditions=>{:email=>params[:email]})
    if existed_member
      render :already_registered
      return
    end
    
    token = EmailRegistrationPending.first(:conditions=>{:email=>params[:email],:_id=>params[:unique_key]})
    
    if !token
      render :invalid_url
      return 
    end
  end
  
  # params[:email]
  def register
    
    params[:email].downcase!
    
    errors = EmailRegistrationValidator.validate(params)
    
    if errors.length > 0
      render :json=>{:ok=>false,:error_messages=>errors}
      return
    end
    
    existed_member = Member.first(:conditions=>{:email=>params[:email]})
    if existed_member
      render :json=>{:ok=>false,:error_messages=>{:email=>word_for(:member,:email_uniqueness)}}
      return
    end

    Resque.enqueue(MemberMailer,:notify_member_confirmation,params[:email])
   
    render :json=>{:ok=>true,:redirect_url=>"/email_registration/please_check_your_email?email=#{params[:email]}"}
  end
  
  # params[:username]
  # params[:password]
  # params[:email]
  # params[:unique_key]
  def create
    
    params[:email].downcase!
    
    existed_member = Member.first(:conditions=>{:email=>params[:email]})
    if existed_member
      render :json=>{:ok=>false,:error_messages=>{:email=>word_for(:member,:email_uniqueness)}}
      return
    end
    
    token = EmailRegistrationPending.first(:conditions=>{:email=>params[:email],:_id=>params[:unique_key]})
    if !token
      render :json=>{:ok=>false,:error_messages=>{:summary=>word_for(:member,:invalid_record)}}
      return
    end

    ok,member,error_messages = process_register(params[:username],params[:password],params[:email].downcase,nil,false)
    
    if ok == false
      render :json=>{:ok=>false,:error_messages=>error_messages}
    else
      token.destroy
      set_member(member)
      render :json=>{:ok=>true,:redirect_url=>"/email_registration/thank_you"}
    end
    
  end
end
