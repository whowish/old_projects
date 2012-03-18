class ResearchController < ApplicationController
    def index
    
    if !params[:country_id] and !params[:entity_id]
      first_entity = Research.first(:order=>"created_date DESC")
  
      if first_entity
        params[:country_id] = first_entity.country_id
        params[:entity_id] = first_entity.id
      end
      
    elsif params[:country_id] and !params[:entity_id]
      
      first_entity = Research.first(:conditions=>{:country_id=>params[:country_id]},:order=>"created_date DESC")
      
      params[:entity_id] = first_entity.id  if first_entity
  
    else !params[:country_id] and params[:entity_id]
  
      first_entity = Research.first(:conditions=>{:id=>params[:entity_id]})
      
      params[:country_id] = first_entity.country_id  if first_entity
  
    end
    
    @entities = Research.all(:conditions=>{:country_id=>params[:country_id]},:order=>"created_date DESC")
    @countries = Country.all(:order=>"name ASC")
    @shown_entity = Research.first(:conditions=>{:id=>params[:entity_id]})
  end
  
end
