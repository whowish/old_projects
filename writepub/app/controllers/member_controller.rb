class MemberController < ApplicationController
  include MemberHelper
 
  
  def login
    strip_all_params
    params[:redirect_url] ||= "/member"
    params[:redirect_url] = "/" if params[:redirect_url] == ""
    
    ok, error_messages = process_login(params[:username],params[:password],params[:remember_me])
    
    if ok == false
      render :json=>{:ok=>false,:error_messages=>error_messages}
    else
      if params[:option] == "receiver_kratoo"
        
        render :json=>{:ok=>true,:kratoo_identity_panel=>render_to_string(:partial=>"kratoo/identity_panel")}
        
      elsif params[:option] == "receiver_reply"
        
        @kratoo = Kratoo.find(params[:kratoo_id])
        
        render :json=>{:ok=>true,
                        :reply_identity_panel=>render_to_string(:partial=>"reply/identity_panel",:locals=>{:kratoo=>@kratoo}),
                        :reply_of_reply_identity_panel=>render_to_string(:partial=>"reply_of_reply/identity_panel",:locals=>{:kratoo=>@kratoo})}
        
      else
        render :json=>{:ok=>true,:redirect_url=>params[:redirect_url]}
      end
    end
    

  end
  
  def logout
    Member.clear_cookies(session,cookies)
    params[:redirect_url] = "/" if !params[:redirect_url] or params[:redirect_url].match("/logout")
    redirect_to params[:redirect_url]
  end
  
  def change_password
    raise Exception, {:summary=>word_for(:change_password,:invalid)} if !$member.is_password_valid(params[:password])
    raise Exception, {:summary=>word_for(:change_password,:please_specify_new_password)} and return if params[:new_password].strip == ""
    
   
    $member.password = Member.encrypt_password(params[:new_password])
    $member.save
    
    render :json=>{:ok=>true}
  rescue Exception=>e
    render :json=>{:ok=>false,:error_message=>e.message}
    
  end
  
  def forget_password
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :json=>{:ok=>false,:error_messages=>{:summary=>"The email is not registered with us."}} and return if !member
    
    Resque.enqueue(MemberMailer,:notify_member_forget_password,member.id)
    
    render :json=>{:ok=>true}
  end
  
  def recover_password_form
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :invalid_url and return if !member

    token = MemberForgetPassword.first(:conditions=>{:member_id=>member.id,:_id=>params[:unique_key]})
    
    render :invalid_url and return if !token
  end
  
  def recover_password
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !member

    token = MemberForgetPassword.first(:conditions=>{:member_id=>member.id,:_id=>params[:unique_key]})
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !token
    render :json=>{:ok=>false,:error_message=>"Please specify password"} and return if params[:password].strip == ""
    
    require 'bcrypt'
    member.password = Member.encrypt_password(params[:password])
    member.save
    token.destroy
    
    process_login(member.email,'',false,true)
    
    render :json=>{:ok=>true}
  end
end
