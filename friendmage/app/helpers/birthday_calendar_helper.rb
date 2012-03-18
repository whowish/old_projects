module BirthdayCalendarHelper
  
  def queue_birthday_calendar_generator(order_key)
    
    entity = BirthdayCalendar.first(:conditions=>{:friendmage_order_key=>order_key})
    
    data = http_post("http://localhost:4567/",{ :order_key=>entity.friendmage_order_key,
                                                :app_id=>"BirthdayCalendar"})
                                          
                                         
  end
  
  def create_birthday_calendar(hash_birthday,order_key)

    entity = BirthdayCalendar.new
    entity.birthday_information = ActiveSupport::JSON.encode(hash_birthday)
    entity.friendmage_order_key = order_key
    entity.background_color = "FFFFFF"
    entity.offset_x = 400
    entity.offset_y = 200
    entity.gap_x = 340
    entity.gap_y = 200
    entity.width = 6000
    entity.year = 2011
    entity.mode = BirthdayCalendar::MODE_ONE_PEOPLE
    entity.created_date = Time.now
    entity.status =  FriendPoster::STATUS_CREATING

    return nil, "", entity.errors.full_messages if !entity.save
    return entity, "http://#{DOMAIN_NAME}/birthday_calendar/preview?order_key=#{entity.friendmage_order_key}"
    
  end
  
  
end
