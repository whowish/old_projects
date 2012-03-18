class MemberController < ApplicationController
  include MemberHelper
  def register
    
    member = Member.first(:conditions=>{:email=>params[:email].strip})
    
    if member and member.status != Member::STATUS_DELETED
      render :json=>{:ok=>false,:error_message=>{
                                                :email=>MemberErrorMessage::EMAIL_NOT_UNIQUE
                                                }
                                }
      return
    end
    
    member = Member.new() if !member
    
    member.email = params[:email]
    member.name = params[:name]
    member.password = ""
    member.status = Member::STATUS_PENDING
    member.member_type = Member::TYPE_GENERAL
    member.is_admin = 0
    member.created_date = Time.now
    
    if !member.save
      error_messages = {:email=>format_single_error(member.errors.on(:email)),
                        :name=>format_single_error(member.errors.on(:name))}
      render :json=>{:ok=>false,:error_message=>error_messages}
      return
    end
    
    MemberMailer.send_later(:deliver_notify_member_confirmation,member)
    
    render :json=>{:ok=>true}
  end
  
  def login_form
    
  end
  
  def login
    
    params[:redirect_url] ||= "/home"
    
    result, error_message = process_login(params[:email],params[:password])
    
    render :json=>{:ok=>result,:redirect_url=>params[:redirect_url],:error_message=>error_message}
  end
  
   def edit
    member = Member.first(:conditions=>{:id=>params[:member_id]})
    member.name = params[:name]

    if !member.save
      error_messages = {:email=>format_single_error(member.errors.on(:email)),
                        :name=>format_single_error(member.errors.on(:name))}
      render :json=>{:ok=>false,:error_message=>error_messages}
      return
    end
    member.update_picture(params[:profile_image_path])
    render :json=>{:ok=>true}
  end
  
  def edit_form
    if $member.is_guest
      redirect_to '/member/login_register?redirect_url='+CGI.escape('/member/edit_form')
    end
  end
  
  def confirm_email
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :invalid_url and return if !member
    render and return if member.status == Member::STATUS_APPROVED
    
    
    
    token = MemberConfirmation.first(:conditions=>{:member_id=>member.id,:unique_key=>params[:unique_key]})
    
    render :invalid_url and return if !token
  end
  
  def set_first_time_password
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :json=>{:ok=>false,:error_message=>"The password had been created before. If you forget password, please use forget password option."}\
      and return if member.status == Member::STATUS_APPROVED
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !member
    #render :json=>{:ok=>false,:error_message=>"The password had been created before. If you forget password, please use forget password option."} \
    #  and return if member.password != nil

    token = MemberConfirmation.first(:conditions=>{:member_id=>member.id,:unique_key=>params[:unique_key]})
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !token
    render :json=>{:ok=>false,:error_message=>"Please specify password"} and return if params[:password].strip == ""
    render :json=>{:ok=>false,:error_message=>"The password and its confirmation do not match."} and return if params[:password] != params[:confirm_password]
    
    require 'digest/md5'
    member.password = Digest::MD5.hexdigest(params[:password])
    member.status = Member::STATUS_APPROVED
    member.save
    
    token.destroy
    
    process_login(member.email,'',true)
    
    render :json=>{:ok=>true}
  end
  
  def forget_password
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :json=>{:ok=>false,:error_message=>"The email is not registered with us."} and return if !member
    
    MemberMailer.send_later(:deliver_notify_member_forget_password,member)
    
    render :json=>{:ok=>true}
  end
  
  def logout
    session[:member_id] = nil
    params[:redirect_url] = "/" if !params[:redirect_url] or params[:redirect_url].match("/logout")
    redirect_to params[:redirect_url]
  end
  
  def recover_password_form
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :invalid_url and return if !member

    token = MemberForgetPassword.first(:conditions=>["member_id=:member_id AND unique_key=:unique_key",{:member_id=>member.id,:unique_key=>params[:unique_key]}]) #,:date=>(Time.now - (15*60)).utc
    
    render :invalid_url and return if !token
  end
  
  def recover_password
    member = Member.first(:conditions=>{:email=>params[:email]})
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !member

    token = MemberForgetPassword.first(:conditions=>["member_id=:member_id AND unique_key=:unique_key AND created_date > :date",{:member_id=>member.id,:unique_key=>params[:unique_key],:date=>(Time.now - (15*60)).utc}])
    
    MemberForgetPassword.delete_all(["created_date < ?",(Time.now - (15*60)).utc])
    
    render :json=>{:ok=>false,:error_message=>"Data is invalid."} and return if !token
    render :json=>{:ok=>false,:error_message=>"Please specify password"} and return if params[:password].strip == ""
    render :json=>{:ok=>false,:error_message=>"The password and its confirmation do not match."} and return if params[:password] != params[:confirm_password]
    
    require 'digest/md5'
    member.password = Digest::MD5.hexdigest(params[:password])
    member.save
    token.destroy
    
    process_login(member.email,'',true)
    
    render :json=>{:ok=>true}
  end
  
  def change_password_form
    if $member.is_guest
      redirect_to '/member/login_register?redirect_url='+CGI.escape('/member/change_password_form')
    end
  end
  
  def change_password
    render :json=>{:ok=>false,:error_message=>{:password=>"The current password is invalid."}} and return if $member.password != Digest::MD5.hexdigest(params[:password])
    render :json=>{:ok=>false,:error_message=>{:new_password=>"Please specify password"}} and return if params[:new_password].strip == ""
    render :json=>{:ok=>false,:error_message=>{:new_password=>"The new password and its confirmation do not match."}} and return if params[:new_password] != params[:confirm_new_password]
    
    require 'digest/md5'
    $member.password = Digest::MD5.hexdigest(params[:new_password])
    $member.save
    
    render :json=>{:ok=>true}
  end
end
