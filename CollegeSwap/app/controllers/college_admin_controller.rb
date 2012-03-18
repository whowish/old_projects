class CollegeAdminController < ApplicationController
  layout "valhalla"
  
  before_filter :check_aesir
  
  def index
    
  end
  
  def remove
    College.delete(params[:college_id])
    render :json=>{:ok=>true}
  end
  
  def link
    
    college = College.first(:conditions=>{:id=>params[:college_id]})
    
    alias_college = College.first(:conditions=>{:name=>params[:alias_name]})
    
    if !alias_college
      render :json=>{:ok=>false,:error_message=>{:alias_college_name => "Cannot find the college in database"}}
    end
    
    if college.update_attributes(:name=>params[:new_name],:college_id=>alias_college.college_id,:status=>College::STATUS_APPROVED)
      render :json=>{:ok=>true}
    else
      render :json=>{:ok=>false, :error_message=>{:alias_college_name => "Cannot be empty."}}
    end
    
  end
  
  
  def save_new
    
    college = College.first(:conditions=>{:id=>params[:college_id]})
    
    if college.update_attributes(:name=>params[:college_name],:status=>College::STATUS_APPROVED)
      render :json=>{:ok=>true}
    else
      render :json=>{:ok=>false, :error_message=>"Cannot be empty"}
    end
  end
  
end
