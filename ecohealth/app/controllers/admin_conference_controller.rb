class AdminConferenceController < AdminController
  include Foundation
  
  CLASS_OBJ = Conference
  
  def save
    
    entity = nil
    entity = CLASS_OBJ.first(:conditions=>{:id=>params[:id]}) if params[:id]
    
    if !entity
      entity = CLASS_OBJ.new()
      entity.created_date = Time.now
    end
    
    entity.country_id = params[:country_id]
    entity.topic = params[:topic]
    entity.description = params[:description]
    
    
    entity.save
    
    entity.update_picture(params[:images])
    render :json=>{:ok=>true}
    
  end
  
  def add_form
    @entity = CLASS_OBJ.new
  end
  
  def edit_form
    @entity = CLASS_OBJ.first(:conditions=>{:id=>params[:id]})
    render :add_form
  end
  
  def delete
    entity = CLASS_OBJ.first(:conditions=>{:id=>params[:id]})
    entity.destroy
    render :json=>{:ok=>true}
  end
end
