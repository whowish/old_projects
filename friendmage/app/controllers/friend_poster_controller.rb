class FriendPosterController < ApplicationController
  include FriendPosterHelper
  include OrderHelper
 
  
  def index
    session[:only_digital] = false
  end
  
  def only_digital
    session[:only_digital] = true
    render :index
  end
  
  def create
    
    flids = params[:friend_list_ids].split(',')
    
    
    qs = ["id=me()"]
    flids.each { |flid| 
      
      sub_query = case flid.downcase
        when "all" then "SELECT uid2 FROM friend WHERE uid1=me()"
        when "family" then "SELECT uid FROM family WHERE profile_id=me()"
        else "SELECT uid FROM friendlist_member WHERE flid='#{flid}'"
      end
      
      qs.push("id IN (#{sub_query})")
    }
    
    image_urls = []
    begin
      image_urls =  $facebook.query("SELECT pic_big FROM profile WHERE #{qs.join(" OR ")}").map{ |d| d['pic_big'] }
    rescue Exception=>e
      if e == FacebookCache::ERROR_INVALID_OAUTH
        @error = true
        render :index
        return
      end
      
      raise e
    end
    
    image_urls.sort! {|x,y| rand(10) <=> 5 }
    
    order = create_order("FriendPoster")
    
    # save image url and order key
    poster, redirect_url, error_message = create_friend_poster(image_urls,order.key)
    
    if !poster
      render :json=>{:ok=>false,:error_message=>error_message}
      return
    end
    
    # generate redirect url and send it back
    render :json=>{:ok=>true,:redirect_url=>redirect_url}
    
  end
  
  def preview
    
    # show canvas according to image_url
    @poster = FriendPoster.first(:conditions=>{:friendmage_order_key=>params[:order_key]})
    @order = Order.first(:conditions=>{:key=>@poster.friendmage_order_key})

    if !([Order::STATUS_PENDING,Order::STATUS_CREATING].include?(@order.status))
      render :template=>"order/order_not_valid"
    end

  end
  
  def save_preview
    
    poster = FriendPoster.first(:conditions=>{:friendmage_order_key=>params[:order_key]})
  
    
    if !poster
      render :json=>{:ok=>false,:error_message=>"The order does not exist."} 
      return 
    end
    
    poster.gap = params[:gap].to_i*10
    poster.background_color = params[:background_color]
    poster.save
    
#    begin
#      queue_friend_poster_generator(poster)
#    rescue Exception=>e
#    end
    
    if poster.status == FriendPoster::STATUS_WAIT_FOR_PAYMENT
      if params[:buy_print_copy] != "true"
        render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/order_successfully?order_key=#{poster.friendmage_order_key}"}
        return 
      else
        render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/address_form?order_key=#{poster.friendmage_order_key}"}
        return 
      end
      
    end
    
    logger.debug { "poster.friendmage_order_key=#{poster.friendmage_order_key}"}
    logger.debug { "poster.status=#{poster.status}"}
    
    if poster.status != FriendPoster::STATUS_CREATING
      render :json=>{:ok=>false,:error_message=>"The order is invalid. It is either paid or cancelled."} 
      return 
    end
    
    price = "80"
    price = "80" if params[:buy_digital_copy]=="true" and params[:buy_print_copy]!="true"
    price = "#{calculate_price(poster)}" if params[:buy_print_copy]=="true"
 
    # submit price
    begin 
      ok, error_message = submit_order_price(poster.friendmage_order_key,price,(params[:buy_digital_copy]=="true"),(params[:buy_print_copy]=="true"))
      session[:only_digital] = false

      if ok == true
        
        poster.status = FriendPoster::STATUS_WAIT_FOR_PAYMENT
        poster.save
        
        # redirect to payment page
        if params[:buy_print_copy] != "true"
          render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/order_successfully?order_key=#{poster.friendmage_order_key}"}
        else
          render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/address_form?order_key=#{poster.friendmage_order_key}"}
        end
        
      else
        render :json=>{:ok=>false,:error_message=>error_message}
      end
    rescue Exception=>e
      render :json=>{:ok=>false,:error_message=>"Error: #{e}"}
    end
  end
  
end

