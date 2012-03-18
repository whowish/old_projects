class CollegeController < ApplicationController
  include ApplicationHelper
  
  def show_dialog
    render :layout=>"blank"  
    
  end
  
  def index
    
     @college_name = ""
 
    if $facebook.college_id != 0
      college = College.first(:conditions=>{:id=>$facebook.college_id})
      @college_name = college.name
    else
#      @college_name = $facebook.college
    end
  end
  
  # params[:college_name]
  def save
    
    render :json=>{:ok=>true,:name=>params[:college_name].strip} if $facebook.is_guest
    
    params[:college_name] = params[:college_name].strip
    
    country_code = params[:country_code]
    
    if params[:college_name] == ""
      render :json=>{:ok=>false,:error_message=>"The college name must not be empty."}
      return
    end
    
    college = College.first(:conditions=>["name LIKE ? AND country_code=?",params[:college_name],country_code])
    
    if !college
      
#      render :json=>{:ok=>false,:error_message=>"The zip code is in valid."}
#      return
      
      college = College.new
      college.name = params[:college_name]
      college.status = College::STATUS_PENDING
      college.country_code = country_code
      
      if !college.save
        render :json=>{:ok=>false,:error_message=>"Cannot be empty."}
        return
      end
      
      college.update_attributes(:college_id => college.id)

    end
    
    
    $facebook.college_id = college.college_id
    
    member = Member.first(:conditions=>{:facebook_id=>$facebook.facebook_id})
    member.update_attributes(:college_id=>$facebook.college_id)
    
    college = College.first(:conditions=>{:id=>$facebook.college_id});
    
    college_name = ""
    college_country_code = "US"
    
    if college
      college_name = college.name
      college_country_code = college.country_code
    end
    
    
    Item.update_all({:owner_university=>college_name,:country_code=>college_country_code},{:facebook_id=>$facebook.facebook_id})
    #connection = ActiveRecord::Base.connection();
    #connection.execute("UPDATE items SET owner_university='"+ get_college_name($facebook.college_id)  +"' WHERE facebook_id ='"+$facebook.facebook_id+"'")

    render :json=>{:ok=>true,:name=>college.name}
  end
  
  def list
    params[:q] = params[:q].strip
    params[:country_code] ||= $facebook.country_code
    
    if params[:q]==""
      render :json => {:result=>[]} 
      return
    end
    
    colleges = College.all(:conditions => ["name LIKE ? AND id = college_id AND country_code=?",params[:q] + '%%', params[:country_code]],:limit=>20)
    
    if colleges.length < 20
      colleges = colleges + College.all(:conditions => ["name LIKE ? AND NOT(name LIKE ?)  AND id = college_id AND country_code=?","%%" + params[:q] + "%%",params[:q] + '%%', params[:country_code]],:limit=>(20-colleges.length))
    end
    
    if params[:all_countries] == "yes"
      if colleges.length < 20
        colleges = College.all(:conditions => ["name LIKE ? AND id = college_id",params[:q] + '%%'],:limit=>(20-colleges.length))
      end
      
      if colleges.length < 20
        colleges = colleges + College.all(:conditions => ["name LIKE ? AND NOT(name LIKE ?)  AND id = college_id","%%" + params[:q] + "%%",params[:q] + '%%'],:limit=>(20-colleges.length))
      end
    end 
    
    render :json => {:result=>colleges.collect{|x| 
        t = x.name
        #t += " (" + x.country_code+")" if params[:all_countries] == "yes"
        t
      }
     }
  end
  
  
end
