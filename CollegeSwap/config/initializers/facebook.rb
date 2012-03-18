class FacebookCache
  include ThumbnailismHelper
  include TraceViewerHelper
  
   attr_accessor :is_aesir,:college_id,:is_new, :country_code
   
#  def self.get_guest
#    return new(:faceook_id=>"0",:name=>"Guest")
#  end
  
  def after_initialize

    @country_code = "US"
    @college_id = 0
    @is_aesir = 0
    @is_new = false
    
    if !is_guest
      member = Member.first(:conditions=>{:facebook_id=>facebook_id})
      
      if !member
        member = Member.create({:facebook_id=>facebook_id,:college_id=>0,:is_aesir=>0})
        @is_new = true
      end
      
      @college_id = member.college_id.to_i
      @is_aesir = member.is_aesir
    end
  end
  

  
  def home_url
    
    if is_guest
      return '#'
    else
      return '/myswappage?user_id='+facebook_id
    end
    
  end
  

  def publish_item(item)
    return if is_guest

    image = ItemImage.first(:conditions=>{:item_id=>item.id},:order=>"ordered_number ASC")

    data = {}
    data['message'] = ""
    data['picture'] = "http://"+DOMAIN_NAME+ item.get_default_category_image(true)+"?"+Time.now.to_i.to_s

    if image
      url = make_thumbnail(image.original_image_path,90,90)
      
      if ENV['S3_ENABLED']
        data['picture'] = 'http://s3.amazonaws.com/'+AWS_S3_BUCKET_NAME+url+"?"+Time.now.to_i.to_s if url
      else
        data['picture'] = "http://"+DOMAIN_NAME+url+"?"+Time.now.to_i.to_s if url
      end
      
    end
    
    print "\n ==== Picture ==== \n" + data['picture'] + "\n"
    
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/item/view?item_id="+item.id.to_s
    
    if item.item_type == Item::ITEM_TYPE_WISH
       data['name'] =  "I want '"+item.title+"'. Who wants to swap?"
    else
      if item.category_id == 4
        data['name'] = "I can '"+item.title+"'. Who wants to swap for my service?"
      else 
        data['name'] = "I have '"+item.title+"' to trade. Who wants to swap?"
      end
      
    end
  
    data['caption'] = "CollegeSwap: " + (Category.find(item.category_id).name rescue "Everything else") 
    data['description'] = item.description
    data['privacy'] = "{'value':'EVERYONE'}"
    
    actions = [{"name" => "View", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/item/view?item_id="+item.id.to_s}]
#    actions = [
#                {"name" => "Hop along", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/hop?bus_id="+bus.id.to_s}
#               ]
    
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    response = ActiveSupport::JSON.decode(post_data("feed",data))

    if response['error']
      return {:ok=>false}.merge(parse_error(response))
    else
      return {:ok=>true}
    end
  end
  
  def publish_request_swap(req)
    return if is_guest

    requestor_item = Item.first(:conditions=>{:id=>req.requestor_item_id})
    responder_item = Item.first(:conditions=>{:id=>req.responder_item_id})
    responder = get_facebook_info(req.responder_facebook_id)

    image = ItemImage.first(:conditions=>{:item_id=>responder_item.id},:order=>"ordered_number ASC")

    data = {}
    data['message'] = ""
    
    data['picture'] = "http://"+DOMAIN_NAME+ responder_item.get_default_category_image(true)+"?"+Time.now.to_i.to_s

    if image
      url = make_thumbnail(image.original_image_path,90,90)
      
      if ENV['S3_ENABLED']
        data['picture'] = 'http://s3.amazonaws.com/'+AWS_S3_BUCKET_NAME+url+"?"+Time.now.to_i.to_s if url
      else
        data['picture'] = "http://"+DOMAIN_NAME+url+"?"+Time.now.to_i.to_s if url
      end
    end
    
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/inbox?filter=pending_response"
    
    responder_item_name = responder_item.title
    responder_item_name += " service" if responder_item.category_id == 4

    requestor_item_name = requestor_item.title
    requestor_item_name += " service" if requestor_item.category_id == 4
    
    if requestor_item.is_money == 1
      data['name'] = "I wanna buy '" + responder_item_name+"' for "+requestor_item.title+" from " + responder.name
    elsif responder_item.is_money == 1
      data['name'] = "I wanna sell '" + requestor_item.title+"' for "+responder_item_name+" to " + responder.name
    else
      data['name'] = "I wanna swap '" + responder_item_name+"' for '"+requestor_item_name+"' with " + responder.name
    end
    
  
    data['caption'] = "CollegeSwap: " + (Category.find(responder_item.category_id).name rescue "Everything else") 
    data['description'] = ""
    data['privacy'] = "{'value':'EVERYONE'}"
    
    actions = [{"name" => "View", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/inbox?filter=pending_response"}]
#    actions = [
#                {"name" => "Hop along", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/hop?bus_id="+bus.id.to_s}
#               ]
    
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    response = ActiveSupport::JSON.decode(post_data("feed",data))

    if response['error']
      return {:ok=>false}.merge(parse_error(response))
    end
    
    data.delete('privacy')
    ActiveSupport::JSON.decode(post_data("feed",data,responder.facebook_id))
    
    
    return {:ok=>true}

  end
  
  def publish_response_swap(req)
    return if is_guest

    responder_item = Item.first(:conditions=>{:id=>req.responder_item_id})
    requestor_item = Item.first(:conditions=>{:id=>req.requestor_item_id})
    requestor = get_facebook_info(req.requestor_facebook_id)

    image = ItemImage.first(:conditions=>{:item_id=>responder_item.id},:order=>"ordered_number ASC")

    data = {}
    data['message'] = ""
    
    data['picture'] = "http://"+DOMAIN_NAME+ responder_item.get_default_category_image(true)+"?"+Time.now.to_i.to_s

    if image
      url = make_thumbnail(image.original_image_path,90,90)
      
      if ENV['S3_ENABLED']
        data['picture'] = 'http://s3.amazonaws.com/'+AWS_S3_BUCKET_NAME+url+"?"+Time.now.to_i.to_s if url
      else
        data['picture'] = "http://"+DOMAIN_NAME+url+"?"+Time.now.to_i.to_s if url
      end
    end
    
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/inbox?filter=accepted"
    
    responder_item_name = responder_item.title
    responder_item_name += " service" if responder_item.category_id == 4

    requestor_item_name = requestor_item.title
    requestor_item_name += " service" if requestor_item.category_id == 4

    if responder_item.is_money == 1
      data['name'] = "I'm gonna buy '"+requestor_item.title+"' for "+responder_item_name+" from " + requestor.name
    elsif requestor_item.is_money == 1
      data['name'] = "I'm gonna sell '"+responder_item_name+"' for "+requestor_item.title+" to " + requestor.name
    else
      data['name'] = "I'm gonna swap '" + responder_item_name+"' with '"+requestor_item_name+"' with " + requestor.name
    end
    
  
    data['caption'] = "CollegeSwap: " + (Category.find(responder_item_name.category_id).name rescue "Everything else") 
    data['description'] = ""
    data['privacy'] = "{'value':'EVERYONE'}"
    
    actions = [{"name" => "View", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/inbox?filter=accepted"}]
#    actions = [
#                {"name" => "Hop along", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/hop?bus_id="+bus.id.to_s}
#               ]
    
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    response = ActiveSupport::JSON.decode(post_data("feed",data))
    
    if response['error']
      return {:ok=>false}.merge(parse_error(response))
    end
    
    data.delete('privacy')
    ActiveSupport::JSON.decode(post_data("feed",data,requestor.facebook_id))
    
    return {:ok=>true}
  end
  
end