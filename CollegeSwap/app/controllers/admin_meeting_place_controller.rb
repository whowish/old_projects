class AdminMeetingPlaceController < ApplicationController
  layout "valhalla"
  def index
    
  end
  
  def save
    college = College.first(:conditions=>{:id=>params[:id]})
    if !college
      render :json=>{:ok=>false,:error_message=>"Cannot find this college."}
      return
    end
    
    college.place_name = params[:place_name]
    college.place_address = params[:place_address]
    college.save
    render :json=>{:ok=>true}
  end
end
