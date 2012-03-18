module EventHelper
   def update_friend(friend_list)
    
    friend_list = friend_list.strip
     
    friends = EventFriend.all(:conditions=>{:event_id=>id})

    new_friend_ids =friend_list.split(",")
    
    new_friend_ids = [] if friend_list == ""
      
      hash_friends = {}
      hash_friends_after_deletion = {}
      new_friend_ids.each {|token|
        f_id,*name = token.split(':')
        hash_friends[f_id] = true
      }
      
      hash_friends_after_deletion = {}
      friend_ids_to_delete = []
 
      friends.each do |friend|
        if !hash_friends[friend.facebook_id]
          friend_ids_to_delete.push(friend.facebook_id)
        else
          hash_friends_after_deletion[friend.facebook_id] = true
        end
      end
      
      EventFriend.delete_all(["event_id = :event_id AND facebook_id in (:ids)",{:event_id=>id,:ids=>friend_ids_to_delete}])
      EventAvailableDate.delete_all(["event_id = :event_id AND facebook_id in (:ids)",{:event_id=>id,:ids=>friend_ids_to_delete}])
    
    new_friends = []
    new_friend_ids.each do |token|
      
      f_id,*name = token.split(':')
      
      name = name.join('')
      
      if !hash_friends_after_deletion[f_id]
        
        eventFriend = EventFriend.new
        eventFriend.event_id = id
        eventFriend.facebook_id = f_id
        eventFriend.status = EventFriend::STATUS_PENDING
        eventFriend.name = name
        new_friends.push(eventFriend)
        
      end
    end
    
    
    if new_friends.length > 0
      all_values = "("+new_friends.map{|o| o.attributes.values.map{ |v| EventFriend.sanitize(v) }.join(",")}.join("),(")+")"
      ActiveRecord::Base.connection.execute("INSERT INTO "+EventFriend.quoted_table_name+" (`"+new_friends[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
    end
  end
  
  def update_available_date(available_date_list)

    available_date_list = available_date_list.strip
    available_dates = available_date_list.split(",")
    available_dates = [] if available_date_list == ""

      EventAvailableDate.delete_all(["event_id = :event_id AND facebook_id = :facebook_id",{:event_id=>id,:facebook_id=>$facebook.facebook_id}])
 
      new_dates = []
      available_dates.each do |date|
        eventAvailableDate = EventAvailableDate.new
        eventAvailableDate.event_id = id
        eventAvailableDate.facebook_id = $facebook.facebook_id
        eventAvailableDate.available_date = date
        new_dates.push(eventAvailableDate)
        
        #print eventAvailableDate.available_date.to_s(:db)+"," + date +" "
      end

      if new_dates.length > 0
        all_values = "("+new_dates.map{|o| o.attributes.values.map{ |v| EventAvailableDate.sanitize(v) }.join(",")}.join("),(")+")"
        #print "INSERT INTO "+EventAvailableDate.quoted_table_name+" (`"+new_dates[0].attributes.keys.join("`,`")+"`) VALUES "+all_values+"\n\n"
        ActiveRecord::Base.connection.execute("INSERT INTO "+EventAvailableDate.quoted_table_name+" (`"+new_dates[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
      end
  end
  
  def update_available_date_scope()
      new_available_dates = EventAvailableDate.all(:conditions=>{:event_id=>id,:facebook_id=>facebook_id})

      EventAvailableDate.delete_all(["event_id = ? AND NOT( available_date in (?))",id,new_available_dates.map{|d| d['available_date']}]);
      
      friend_ids = EventAvailableDate.all(:select=>"DISTINCT facebook_id",:conditions=>{:event_id=>id})
      
      EventFriend.update_all(["status=?",EventFriend::STATUS_PENDING],["status=:status AND event_id=:event_id AND NOT(facebook_id IN (:ids))",{:event_id=>id,:status=>EventFriend::STATUS_ACCEPTED,:ids=>friend_ids.map{|d|d.facebook_id}}])
  end
  
  def update_settled_date(settled_date_list)

    settled_date_list = settled_date_list.strip
    settled_dates = settled_date_list.split(",")
    settled_dates = [] if settled_date_list == ""

      EventSettledDate.delete_all(["event_id = :event_id",{:event_id=>id}])
 
      new_dates = []
      settled_dates.each do |date|
        eventSettledDate = EventSettledDate.new
        eventSettledDate.event_id = id
        eventSettledDate.settled_date = date
        new_dates.push(eventSettledDate)
      end
    
      if new_dates.length > 0
        all_values = "("+new_dates.map{|o| o.attributes.values.map{ |v| EventSettledDate.sanitize(v) }.join(",")}.join("),(")+")"
        ActiveRecord::Base.connection.execute("INSERT INTO "+EventSettledDate.quoted_table_name+" (`"+new_dates[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
      end
  end
  
  def get_best_date(event)
    connection = ActiveRecord::Base.connection
    sql = "SELECT available_date,count(1) FROM event_available_dates WHERE event_id = '" + event.id.to_s + "' GROUP BY available_date ORDER BY 2 DESC, available_date ASC"
    result = connection.execute(sql)
    return_value = []
   
    while true
     row = result.fetch_row
     break if row == nil
     r = {"date"=>row[0],"count"=>row[1].to_i}
     return_value.push(r)
    end
   
    return return_value
  end
  
  def send_mail_all_friend(event,mail_type)
    creator = get_facebook_info(event.facebook_id)
    friends = EventFriend.all(:conditions=>{:event_id=>event.id})
    
    friends.each do |friend|
      receiver = FacebookCache.first(:conditions=>{:facebook_id=>friend.facebook_id})
      
      next if !receiver
      next if !(receiver.email)
      
      if mail_type == UserMailer::NOTIFY_CREATE
        UserMailer.send_later(:deliver_notify_create_event,event,creator,receiver)
      elsif mail_type == UserMailer::NOTIFY_EDIT
        UserMailer.send_later(:deliver_notify_edit_event,event,creator,receiver)
      elsif mail_type == UserMailer::NOTIFY_CANCEL
        UserMailer.send_later(:deliver_notify_cancel_event,event,creator,receiver)
      elsif mail_type == UserMailer::NOTIFY_SETTLED_DATE   
        UserMailer.send_later(:deliver_notify_settled_date,event,creator,receiver)
      elsif mail_type == UserMailer::NOTIFY_CANCEL_SETTLED_DATE   
        UserMailer.send_later(:deliver_notify_cancel_settled_date,event,creator,receiver)
      end
    end
  end
  
  def send_mail_comment(event,comment,mail_type)
    creator = get_facebook_info(comment.facebook_id)
    friends = EventFriend.all(:conditions=>{:event_id=>event.id})
    
    friends.each do |friend|
      if friend.facebook_id == comment.facebook_id
        next
      end
      receiver = FacebookCache.first(:conditions=>{:facebook_id=>friend.facebook_id})
      
      next if !receiver
      next if !(receiver.email)
      
      if mail_type == UserMailer::NOTIFY_COMMENT  
        UserMailer.send_later(:deliver_notify_comment,event,creator,receiver)
      end
    end
    
    #send mail to event's creator
    if mail_type == UserMailer::NOTIFY_COMMENT and comment.facebook_id != event.facebook_id
      receiver = FacebookCache.first(:conditions=>{:facebook_id=>event.facebook_id})
      UserMailer.send_later(:deliver_notify_comment,event,creator,receiver)
    end
    
  end
end
