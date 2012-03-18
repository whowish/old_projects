class ProfileController < ApplicationController

  def index
    if !params[:user_id] and $facebook.is_guest
      render :not_login
    end
  end

  def change_name
    member = Member.first(:conditions=>{:facebook_id => $facebook.facebook_id})
    if !member
      render :json=>{:ok=>false, :error_message=>"please login."}
      return
    end
    
    avaiable_user_name = Member.first(:conditions=>{:anonymous_name => params[:anonymous_name]})
    if avaiable_user_name and avaiable_user_name.facebook_id != $facebook.facebook_id
      render :json=>{:ok=>false, :error_message=>"This name is already taken!"}
      return
    end
    
    member.anonymous_name = params[:anonymous_name].downcase
    member.save
    
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"profile/side_anonymous_name",:locals=>{:user=>member})}
  end
  
  def ban
    member = Member.first(:conditions=>{:facebook_id => params[:facebook_id]})
    if !member
      render :json=>{:ok=>false, :error_message=>"invalid user!"}
      return
    end
    member.status = Member::STATUS_BANNED
    member.save
    render :json=>{:ok=>true}
  end
end
