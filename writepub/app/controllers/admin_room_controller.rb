class AdminRoomController < ApplicationController
  respond_to :html, :json
  # params[:tag_name]
  def create
    
    strip_all_params
    
    tag = Tag.first(:conditions=>{:name=>params[:tag_name]})
    
    if !tag
      raise "'#{params[:tag_name]}' is not found."  
    end
    
    room = Room.first(:conditions=>{:tag=>tag.name})
    
    if room
      raise "'#{params[:tag_name]}' is already a room."
    end
    
    room = Room.create(:tag=>tag.name,:ordered_number=>0,:description=>"")
    
    
    render :json=>{:ok=>true,:room_id=>room.id,:tag_name=>tag.name}
  rescue Exception=>e
    render :json=>{:ok=>false,:error_message=>e.message}
  end
  
  def remove
    room = Room.first(:conditions=>{:_id=>params[:room_id]})
    
    room.destroy if room
    
    render :json=>{:ok=>true}
  end
  
end
