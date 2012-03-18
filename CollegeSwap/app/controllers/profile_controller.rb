class ProfileController < ApplicationController
  include Foundation
  
  def save
    member = Member.first(:conditions=>{:facebook_id=>$facebook.facebook_id})
    
    member.profile_text = params[:profile_text]
    member.save
    
    render :json=>{:ok=>true,:profile_text=>member.profile_text}
  end
end
