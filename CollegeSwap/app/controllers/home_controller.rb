class HomeController < ApplicationController
  
  def load_more
    
    params[:anchor] = 0 if !params[:anchor]
    
    params[:category_id] = 0 if !params[:category_id]
    params[:category_id] = params[:category_id].to_i
    
    params[:college_name] = "" if !params[:college_name]
    params[:college_name] = params[:college_name].strip

    sql = "true "
    
    sql += " AND ((privacy = '"+Item::PRIVACY_ALL+"') " +
    " OR (privacy = '"+Item::PRIVACY_FRIENDS+"' AND facebook_id IN (?))" +
    " OR (privacy = '"+Item::PRIVACY_FRIENDS_OF_FRIENDS+"' AND facebook_id IN (?)))"
    
    friends = $facebook.all_friends
    friends_of_friends = $facebook.all_friends_of_friends

    friends.push($facebook.facebook_id)
    friends_of_friends.push($facebook.facebook_id)
    
    sql_params = [friends,friends_of_friends]
    if params[:category_id] != 0
      category_ids = [params[:category_id]]
      cats = Category.all(:conditions=>{:parent_id=>params[:category_id]})
      cats.each { |c|
        category_ids.push(c.id);
      }
      
      sql += " AND category_id in (?)"
      sql_params.push(category_ids)
    end
    
    if params[:college_name] != ""
      college = College.first(:conditions=>["name LIKE ?",params[:college_name]])
      
      if college
        if college.id != college.college_id
          college = College.first(:conditions=>{:id=>college.college_id})
        end
        
        sql += " AND owner_university = ?"
        sql_params.push(college.name)
      else
        sql += " AND 0"
      end
    else
      sql += " AND country_code = '"+$facebook.country_code+"'"
    end
    
    sql += " AND status=? AND is_money=0 " + session[:flagged_item_sql]
    sql_params.push(Item::STATUS_ACTIVE)
    
    if params[:anchor].to_i > 0
      sql += " AND NOT(facebook_id = ?)"
      sql_params.push($facebook.facebook_id)
    end
    
    sql += " AND id > ?"
    sql_params.push(params[:anchor])
    
    
    sql_params.unshift(sql)
    items = []
    if params[:anchor].to_i == 0
      items = Item.all(:conditions=>sql_params,:order=>"id DESC",:limit=>10)
    else
      items = Item.all(:conditions=>sql_params,:order=>"id DESC")
    end
    
  
    if items.length == 0
      render :json=>{:ok=>false}
      return
    end
    
    anchor = items[0].id
    results = []
    
    items.each { |item| 
      results.push(render_to_string(:partial=>"home/search_result_unit",:locals=>{:item=>item}))
    }
    
    render :json=>{:ok=>true,:anchor=>anchor,:results=>results}
  end

  
end
