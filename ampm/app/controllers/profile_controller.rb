class ProfileController < ApplicationController
  def index 
    
  end
  def get_email
    if $facebook.email == nil
      user = get_facebook_info($facebook.facebook_id,true)
      $facebook.email = user.email
    end
    
    render :index
  end
end
