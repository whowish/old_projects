module FriendPosterHelper
  
  def queue_friend_poster_generator(order_key)
    
    poster = FriendPoster.first(:conditions=>{:friendmage_order_key=>order_key})
    
    data = http_post("http://localhost:4567/",{ :order_key=>poster.friendmage_order_key,
                                                :app_id=>"FriendPoster"})                        
  end
  
  def calculate_price(poster)
    
    base_inch = 20
    base_friend = 400
    
    # calculate
    num_friends = poster.image_urls.split(',').length
    
    return 300 if num_friends <= base_friend
    
    poster.save
    
    inch = (poster.height.to_f / 300).ceil
    
    return 300 if inch < base_inch
    return 300 + ((inch-base_inch) * 5)
  end
  
  def create_friend_poster(image_urls,order_key)

    poster = FriendPoster.new
    poster.image_urls = image_urls.join(',')
    poster.friendmage_order_key = order_key
    poster.gap = 20
    poster.border = 100
    poster.background_color = "000000"
    poster.photo_per_row = 20
    poster.width = 6000
    poster.created_date = Time.now
    poster.status =  FriendPoster::STATUS_CREATING

    return nil, "", poster.errors.full_messages if !poster.save
    return poster, "http://#{DOMAIN_NAME}/friend_poster/preview?order_key=#{poster.friendmage_order_key}"
    
  end
  
end
