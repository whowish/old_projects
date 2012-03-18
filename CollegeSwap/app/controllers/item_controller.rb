class ItemController < ApplicationController
  include ItemHelper
  include FacebookHelper
  include ApplicationHelper
  def index
    
  end
  
  def add
    @item = Item.new()
    @item.title = params[:title]
    @item.item_type = params[:item_type].upcase
    @item.value =  params[:value]
    @item.expiration_date =  params[:expiration_date]
    
    if params[:expiration_date].strip != "" and params[:expiration_date] != nil
      @item.expiration_date =  params[:expiration_date] + " 23:59:59"
    end
    
    @item.description = params[:description]
    @item.facebook_id = $facebook.facebook_id
    @item.owner_name = $facebook.name
    @item.owner_university = get_college_name($facebook.college_id)
    @item.country_code = $facebook.country_code

    @item.category_id = params[:category_id]
    @item.status = Item::STATUS_ACTIVE
    @item.status = Item::STATUS_PENDING if $facebook.is_guest
    @item.created_date = Time.now
    @item.is_money = 0
    @item.privacy = params[:privacy]
    
    if !@item.save
      render :json=>{:ok=>false, :error_message=>format_error(@item.errors)}
      return
    end

    @item.update_picture(params[:images])
    
    @item.default_image_path = ""
    
    default_image = ItemImage.first(:conditions=>{:item_id => @item.id})
    @item.default_image_path = default_image.original_image_path if default_image
    @item.save
    
    html = render_to_string :partial=>"home/item",:locals=>{:entity=>@item,:mode=>MODE_SWAP_PAGE}
    search_result_unit_html = render_to_string :partial=>"home/search_result_unit",:locals=>{:item=>@item}
   
    is_redirect = false
    is_share = "no"
    scope = []
    result = {}
    
    if $facebook.facebook_id == "0"
      is_redirect = true
      
      if params[:share_on_facebook] == "yes"
        is_share = "yes"
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
      end
    else
      if params[:share_on_facebook] == "yes"
        is_share = "yes"
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_item(@item)
      end
    end
    
    if is_redirect == true or (result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION)
      
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"Add item" + @item.id.to_s) 
      
      return_url = "http://#{DOMAIN_NAME}/item/share_after_add/#{@item.id.to_s}/#{ticket.unique_key}/#{is_share}"
      redirect_url = generate_permission_url(scope,return_url)
      
      render :json=>{:ok=>true,:html=>html,:search_result_unit_html=>search_result_unit_html,:item_id=>@item.id,:redirect_url=>redirect_url}
      return
    end
    
    render :json=>{:ok=>true,:html=>html,:search_result_unit_html=>search_result_unit_html,:item_id=>@item.id}
  end
  
  def edit
    @item = Item.first(:conditions=>{:id=> params[:item_id]})
    @item.title = params[:title]
    @item.value =  params[:value]
    @item.expiration_date =  params[:expiration_date]
  
    if params[:expiration_date] != "" and params[:expiration_date] != nil
      @item.expiration_date =  params[:expiration_date] + " 23:59:59"
    end
    
    @item.description = params[:description]
    @item.category_id = params[:category_id]
    @item.privacy = params[:privacy]
    
    if !@item.save
      render :json=>{:ok=>false, :error_message=>format_error(@item.errors)}
      return
    end

    @item.update_picture(params[:images])
    
    @item.default_image_path = ""
    
    default_image = ItemImage.first(:conditions=>{:item_id => @item.id})
    @item.default_image_path = default_image.original_image_path if default_image
    @item.save
    
    html = render_to_string :partial=>"home/item",:locals=>{:entity=>@item,:mode=>MODE_SWAP_PAGE}
   
    if params[:share_on_facebook] == "yes"
      scope = [FacebookCache::SCOPE_PUBLISH_STREAM]
      result = $facebook.publish_item(@item)
      
      if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
        
        ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"Edit item" + @item.id.to_s) 
        
        return_url = "http://#{DOMAIN_NAME}/item/share_after_add/#{@item.id}/#{ticket.unique_key}/yes"
        redirect_url = generate_permission_url(scope,return_url)
        
        render :json=>{:ok=>true,:html=>html,:item_id=>@item.id,:redirect_url=>redirect_url}
        return
      end
    end

     render :json=>{:ok=>true,:html=>html,:item_id=>@item.id}
  end
  
  def share
#    begin
#      inner_share(params[:item_id])
#    rescue => e
#        if e.to_s == "No permission"
#          @redirect_url = "http://www.facebook.com/dialog/oauth/?" +
#                  "client_id=" + APP_ID +
#                  "&scope=publish_stream" +
#                  "&redirect_uri=http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/item/share_after_add?item_id="+params[:item_id]
#        elsif e.to_s == "Limit reached"
#          @error_message = "You cannot share because your publish limit has been exceeded."
#        else 
#          print e.backtrace
#          raise e
#        end
#    end
      scope = [FacebookCache::SCOPE_PUBLISH_STREAM]
      item = Item.first(:conditions=>{:id=>params[:item_id]})
      return if !item
    
      result = $facebook.publish_item(item) if item and item.facebook_id == $facebook.facebook_id
      if result[:ok] == true
        return
      end
      
      if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
        
        ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"Share item" + params[:item_id]) 
        
        return_url = "http://#{DOMAIN_NAME}/item/share_after_add/#{params[:item_id]}/#{ticket.unique_key}/yes"
        @redirect_url = generate_permission_url([FacebookCache::SCOPE_PUBLISH_STREAM],return_url)
      else
        @error_message = result[:error_message]
      end
  end
  
  def share_after_add
    item = Item.first(:conditions=>{:id=>params[:item_id]})
    
    if item.facebook_id == "0" and !$facebook.is_guest
      item.facebook_id = $facebook.facebook_id
      item.owner_name = $facebook.name
      item.owner_university = get_college_name($facebook.college_id)
      item.status = Item::STATUS_ACTIVE
      item.save
    end
    
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      if params[:is_share] == "yes"
          result = inner_share(params[:item_id])
      end
      
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to "/"    
   
  end
  
  def delete
    delete_item = Item.first(:conditions=>{:id=> params[:item_id]})
    delete_item.status = Item::STATUS_DELETED
    delete_item.save
    render :json=>{:ok=>true}
  end
 
   def get_seed_new_college
    seed = ""
    File.open('public/japan.txt').each_line{ |college|
      college = college.strip
      if college != "" and college != "\n" and college != "\r"
        college_db = College.first(:conditions=>{:name=> college})
        if college_db == nil
          seed += "College.create({ :status=>College::STATUS_APPROVED,:country_code=>\"JP\", :name =>\"" + college + "\"})" +  "\n" + "<br/>"
        end
      end
    }
    render :text=>seed
  end
  
  def get_seed_college
    seed = ""
    colleges = College.all()
    colleges.each do |c|
      upcase_c = c.name.upcase
      if upcase_c.end_with?(" UNIVERSITY")
        new_college = c.name[0...c.name.length-11]
        seed += "College.create({ :status=>College::STATUS_APPROVED, :name =>\"" + new_college + "\", :college_id=>" + c.id.to_s+"})" +  "\n" + "<br/>"
      end
    end
    
    render :text=>seed
  end
  
  def suggest_wish
    wish = ""
    wishes = get_suggest_item($facebook,5)
    if wishes.length == 0
      render :text=>"no wishes"
      return
    end
    
    wishes.each do |w|
      
      wish += w.title + "<br/>"
    end
    render :text=>wish
  end
  
  def view
    @item = Item.first(:conditions=>{:id=> params[:item_id]})
  end
  
  
  
   private
  def inner_share(item_id)
    
    item = Item.first(:conditions=>{:id=>item_id})
    return {:ok=>false,:error_message=> "Item "+item_id+" does not exist"} if !item
    
    return $facebook.publish_item(item) if item and item.facebook_id == $facebook.facebook_id

  end

  
end
