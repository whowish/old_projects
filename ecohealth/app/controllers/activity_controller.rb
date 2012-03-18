class ActivityController < ApplicationController
  
  def index
    
    if !params[:country_id] and !params[:activity_id]
      first_entity = Activity.first(:order=>"created_date DESC")
  
      if first_entity
        params[:country_id] = first_entity.country_id
        params[:activity_id] = first_entity.id
      end
      
    elsif params[:country_id] and !params[:activity_id]
      
      first_entity = Activity.first(:conditions=>{:country_id=>params[:country_id]},:order=>"created_date DESC")
      
      params[:activity_id] = first_entity.id  if first_entity
  
    else !params[:country_id] and params[:activity_id]
  
      first_entity = Activity.first(:conditions=>{:id=>params[:activity_id]})
      
      params[:country_id] = first_entity.country_id  if first_entity
  
    end
    
    @activities = Activity.all(:conditions=>{:country_id=>params[:country_id]},:order=>"created_date DESC")
    @countries = Country.all(:order=>"name ASC")
    @shown_activity = Activity.first(:conditions=>{:id=>params[:activity_id]})
  end
  
end
