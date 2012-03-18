class FacebookRegistrationController < ApplicationController
  include MemberHelper
  include FacebookRegistrationHelper
  
  # params[:code]
  # params[:redirect_path]
  def index
    
    params[:redirect_path] ||= ""
    
    # check code
    @facebook = facebook_connect(params[:code],"http://#{DOMAIN_NAME}/facebook_registration/#{params[:redirect_path]}")
    
    if @facebook == nil or @facebook.facebook_id == nil
      render :facebook_connect_failed 
      return
    end
    
    set_facebook(@facebook)
    
    member = Member.first(:conditions=>{:facebook_id=>@facebook.facebook_id})
    
    if !member
      
      render :index
      
    else
      set_member(member)
      
      command,kratoo_id = process_redirect_path(params[:redirect_path])
      
      case command 
        when "receiver/kratoo"
          
          render :receiver_kratoo
          
        when "receiver/reply"
          
          params[:kratoo_id] = kratoo_id
          render :receiver_reply
          
        else
          redirect_to command
      end
      
      
    end
    
    
  end
  
  # params[:username]
  # params[:password]
  # session[:facebook_oauth_token]
  def create
    
    @facebook = FacebookUser.get_facebook_user(session[:facebook_oauth_token])
    render :facebook_connect_failed if @facebook == nil or @facebook.facebook_id == nil
    
    existed_member = Member.first(:conditions=>{:facebook_id=>@facebook.facebook_id})
    if existed_member
      set_member(existed_member)
      render :json=>{:ok=>false,:error_messages=>{:summary=>word_for(:member,:facebook_id_uniqueness)}}
      return
    end
    
    ok,member,error_messages = process_register(params[:username],
                              params[:password],
                              nil,
                              @facebook.facebook_id,
                              (@facebook.get_friend_count > 20))
                              
    if ok == false
      render :json=>{:ok=>false,:error_messages=>error_messages}
    else
      set_member(member)
      
      command,kratoo_id = process_redirect_path(params[:redirect_path])
    
      case command
        when "receiver/kratoo"
          render :json=>{:ok=>true,:redirect_url=>"/facebook_registration/receiver_kratoo"}
        when "receiver/reply"
          render :json=>{:ok=>true,:redirect_url=>"/facebook_registration/receiver_reply?kratoo_id=#{kratoo_id}"}
        else
          render :json=>{:ok=>true,:redirect_url=>command}
      end
      
      return
    end
                              

  end

  private
    def process_redirect_path(redirect_path)
      if redirect_path == "receiver/kratoo"
        return "receiver/kratoo",""
      elsif data = redirect_path.match("receiver/reply/(.+)")
        return "receiver/reply",data[1]
      elsif data = redirect_path.match("receiver/reply_of_reply/(.+)")
        return "receiver/reply_of_reply",data[1]
      else
        return "/#{params[:redirect_path]}"
      end
    end
end
