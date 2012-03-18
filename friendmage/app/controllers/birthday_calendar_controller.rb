class BirthdayCalendarController < ApplicationController
  include BirthdayCalendarHelper
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

    qs = ["uid=me()"]
    flids.each { |flid| 
      
      sub_query = case flid.downcase
        when "all" then "SELECT uid2 FROM friend WHERE uid1=me()"
        when "family" then "SELECT uid FROM family WHERE profile_id=me()"
        else "SELECT uid FROM friendlist_member WHERE flid='#{flid}'"
      end
      
      qs.push("uid IN (#{sub_query})")
    }
    
    birthday_with_pics = []
    begin
      birthday_with_pics =  $facebook.query("SELECT name,pic_big,birthday_date FROM user WHERE #{qs.join(" OR ")}")
    rescue Exception=>e
      if e == FacebookCache::ERROR_INVALID_OAUTH
        @error = true
        render :index
        return
      end
      
      raise e
    end
    
    hash_birthday = {}
    birthday_with_pics.each { |b|
      
      next if b['birthday_date'] == nil
   
      month,day,year = b['birthday_date'].split('/')
      
      indexing_key = "#{month}-#{day}"
      
      hash_birthday[indexing_key] = [] if !hash_birthday[indexing_key]
      hash_birthday[indexing_key].push({:url=>b['pic_big'],:name=>b['name'].gsub('"','"')})
    }
    
    order = create_order("BirthdayCalendar")
    
    # save image url and order key
    entity, redirect_url, error_message = create_birthday_calendar(hash_birthday,order.key)
    
    if !entity
      render :json=>{:ok=>false,:error_message=>error_message}
      return
    end
    
    # generate redirect url and send it back
    render :json=>{:ok=>true,:redirect_url=>redirect_url}
    
  end

  def preview
    
    # show canvas according to image_url
    @entity = BirthdayCalendar.first(:conditions=>{:friendmage_order_key=>params[:order_key]})
    @order = Order.first(:conditions=>{:key=>@entity.friendmage_order_key})

    if !([Order::STATUS_PENDING,Order::STATUS_CREATING].include?(@order.status))
      render :template=>"order/order_not_valid"
    end
    
  end
  
  def save_preview
    
    entity = BirthdayCalendar.first(:conditions=>{:friendmage_order_key=>params[:order_key]})
    order = Order.first(:conditions=>{:key=>params[:order_key]})
    
    if !entity
      render :json=>{:ok=>false,:error_message=>"The order does not exist."} 
      return 
    end
    
    entity.mode = params[:mode]
    entity.birthday_information = params[:birthday_information]
    entity.save
    
#    begin
#      queue_friend_poster_generator(poster)
#    rescue Exception=>e
#    end
    
    if entity.status == BirthdayCalendar::STATUS_WAIT_FOR_PAYMENT
      if params[:buy_print_copy] != "true"
        render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/order_successfully?order_key=#{entity.friendmage_order_key}"}
        return 
      else
        render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/address_form?order_key=#{entity.friendmage_order_key}"}
        return 
      end
      
    end
    
    if entity.status != BirthdayCalendar::STATUS_CREATING
      render :json=>{:ok=>false,:error_message=>"The order is invalid. It is either paid or cancelled."} 
      return 
    end
    
    price = "80"
    price = "80" if params[:buy_digital_copy]=="true" and params[:buy_print_copy]!="true"
    price = "380" if params[:buy_print_copy]=="true"
    
    # submit price
    begin 
      ok, error_message = submit_order_price(entity.friendmage_order_key,price,(params[:buy_digital_copy]=="true"),(params[:buy_print_copy]=="true"))
      session[:only_digital] = false

      if ok == true
        
        entity.status = BirthdayCalendar::STATUS_WAIT_FOR_PAYMENT
        entity.save
        
        # redirect to payment page
        if params[:buy_print_copy] != "true"
          render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/order_successfully?order_key=#{entity.friendmage_order_key}"}
        else
          render :json=>{:ok=>true,:redirect_url=>"http://#{DOMAIN_NAME}/order/address_form?order_key=#{entity.friendmage_order_key}"}
        end
        
      else
        render :json=>{:ok=>false,:error_message=>error_message}
      end
    rescue Exception=>e
      render :json=>{:ok=>false,:error_message=>"Error: #{e}"}
    end
  end

end
