class EventController < ApplicationController
  include EventHelper
  include FacebookHelper
  include ApplicationHelper
  
  def index 
    
  end
  
  def view
     @event = Event.first(:conditions=>{:id => params[:event_id]})
     
     redirect_to "/" if !@event
  end
  
  def add
    @event = Event.new()
    @event.title = params[:title]
    @event.location = params[:location]
    @event.location_url = params[:location_url]
    @event.description = params[:description]
    @event.category_id = params[:category_id]
    @event.facebook_id = $facebook.facebook_id
    @event.settled_date = params[:available_dates].split(',')[0]
    @event.status = Event::STATUS_ACTIVE
    @event.created_date = Time.now
    @event.mode = params[:mode]
    
    if !@event.save
      render :json=>{:ok=>false, :error_message=>format_error(@event.errors)}
      return
    end

    @event.update_available_date(params[:available_dates])
    
    @event.update_friend(params[:friends])
    
    @event.update_picture(params[:images])
    @event.default_image_path = ""
    default_image = EventImage.first(:conditions=>{:event_id => @event.id})
    @event.default_image_path = default_image.original_image_path if default_image
    @event.save

    send_mail_all_friend(@event,UserMailer::NOTIFY_CREATE)
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_invite(@event)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"Add event" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_add?event_id="+@event.id.to_s+"&share_unique_key="+ticket.unique_key+"&is_share=yes&is_edit=no"
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end

    render :json=>{:ok=>true,:event_id=>@event.id}

  end
  
  def edit
    @event = Event.first(:conditions=>{:id => params[:event_id]})
    @event.title = params[:title]
    @event.location = params[:location]
    @event.location_url = params[:location_url]
    @event.description = params[:description]
    @event.category_id = params[:category_id]
    
    @event.update_friend(params[:friends])
    
    @event.update_available_date(params[:available_dates])
    @event.update_available_date_scope()
    
    best_date = get_best_date(@event)
    first_settled_date = EventAvailableDate.first(:conditions=>{:event_id => @event.id, :facebook_id=>$facebook.facebook_id },:order=>"available_date asc")
    @event.settled_date = first_settled_date if first_settled_date
    @event.settled_date = best_date[0]['date'] if best_date.length > 0
    
    @event.update_picture(params[:images])
    @event.default_image_path = ""
    
    default_image = EventImage.first(:conditions=>{:event_id => @event.id})
    @event.default_image_path = default_image.original_image_path if default_image
 
    if !@event.save
      render :json=>{:ok=>false, :error_message=>format_error(@event.errors)}
      return
    end
    
    send_mail_all_friend(@event,UserMailer::NOTIFY_EDIT)

    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_edit(@event)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"Add event" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_add?event_id="+@event.id.to_s+"&share_unique_key="+ticket.unique_key+"&is_share=yes&is_edit=yes"
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end

    render :json=>{:ok=>true,:event_id=>@event.id}
    
  end
  
  def delete
    @event = Event.first(:conditions=>{:id => params[:event_id]})
    @event.status = Event::STATUS_DELETED
    
    if !@event.save
      render :json=>{:ok=>false, :error_message=>format_error(@event.errors)}
      return
    end
    
    send_mail_all_friend(@event,UserMailer::NOTIFY_CANCEL)
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_delete(@event)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"delete event" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_delete?event_id="+@event.id.to_s+"&share_unique_key="+ticket.unique_key
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end
    

    render :json=>{:ok=>true,:event_id=>@event.id}
    
  end
  
  def save_response
    
    event_friend_response = EventFriend.first(:conditions=>{:event_id => params[:event_id], :facebook_id=>$facebook.facebook_id})
   
    event_friend_response.status = EventFriend::STATUS_ACCEPTED   
    event_friend_response.status = EventFriend::STATUS_REJECTED if params[:available_dates] == ""
    event_friend_response.save
    
    @event = Event.first(:conditions=>{:id => params[:event_id]})
    @event.update_available_date(params[:available_dates])
    
    best_date = get_best_date(@event)
    first_settled_date = EventAvailableDate.first(:conditions=>{:event_id => @event.id, :facebook_id=>$facebook.facebook_id },:order=>"available_date asc")
    @event.settled_date = first_settled_date if first_settled_date
    @event.settled_date = best_date[0]['date'] if best_date.length > 0
    @event.save
    
    creator = get_facebook_info(@event.facebook_id)
    responder = get_facebook_info($facebook.facebook_id)
    if creator and creator.email
      UserMailer.send_later(:deliver_notify_response,@event,creator,responder,event_friend_response.status == EventFriend::STATUS_ACCEPTED)
    end
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_response(@event,event_friend_response)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"response" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_response?event_id="+@event.id.to_s+"&event_friend_id="+event_friend_response.id.to_s+"&share_unique_key="+ticket.unique_key
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end

    render :json=>{:ok=>true,:event_id=>@event.id}
    
  end
  
  def invite_more_friend
    
    event = Event.first(:conditions=>{:id=>params[:event_id]})
    new_friend = params[:friends].split(",")
    
    friend_ids = []
    new_friend.each do |f|
      f_split = f.split(':')
      
      count = EventFriend.count(:conditions=>{:event_id=>event.id,:facebook_id=>f_split[0]})
      next if count > 0
      
      friend = EventFriend.new()
      friend.event_id = params[:event_id]
      friend.facebook_id = f_split[0]
      friend.name = f_split[1]
      friend.status = EventFriend::STATUS_PENDING
      friend.is_approved = 0
      friend.is_approved = 1 if event.facebook_id == $facebook.facebook_id
      friend.invited_by = $facebook.facebook_id
      friend.save
      
      friend_ids.push(f_split[0]);
    end
    
    if params[:share_on_facebook] == "yes"
        scope = [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_invite(event,friend_ids)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
          
          ref_data = {:event_id=>event.id,:friend_ids=>friend_ids}
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>ref_data.to_json) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_invite?share_unique_key="+ticket.unique_key+"&is_share=yes&is_edit=yes"
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json=>{:ok=>true,:event_id=>event.id,:redirect_url=>redirect_url}
          return
        end
    end


    render :json=>{:ok=>true,:event_id=>params[:event_id]}
    
  end
  
  def share_after_invite
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    data = JSON.parse(ticket.ref)
    
    event = Event.first(:conditions=>{:id=>data['event_id']})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      if params[:is_share] == "yes"
          result = $facebook.publish_invite(event,data['friend_ids'])
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
     
    redirect_to "/event/view?event_id="+ data['event_id'].to_s
  end
  
  def accept_friend
    
    friend = EventFriend.first(:conditions=>{:id => params[:event_friend_id]})
    
    if friend
      friend.is_approved = 1
      friend.save
    end

    render :json=>{:ok=>true}
    
  end
  
   def reject_friend
    
    friend = EventFriend.first(:conditions=>{:id => params[:event_friend_id]})
    
    if friend
      friend.destroy
      EventAvailableDate.delete_all(["event_id = :event_id AND facebook_id = (:id)",{:event_id=>friend.event_id,:id=>friend.facebook_id}])
    end

    render :json=>{:ok=>true}
    
  end
  
  def settled_date
    @event = Event.first(:conditions=>{:id => params[:event_id]})
    
    @event.update_settled_date(params[:settled_dates])

    
    first_settled_date = EventSettledDate.first(:conditions=>{:event_id => @event.id},:order=>"settled_date asc")
    
    @event.settled_date = first_settled_date.settled_date
    @event.status = Event::STATUS_SETTLED
    @event.save
    
    send_mail_all_friend(@event,UserMailer::NOTIFY_SETTLED_DATE)
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_settle(@event)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"settle" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_settled?event_id="+@event.id.to_s+"&share_unique_key="+ticket.unique_key+"&is_cancel=no"
          redirect_url = generate_permission_url(scope,return_url)
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end

    render :json=>{:ok=>true,:event_id=>@event.id}
    
  end
  
  def cancel_settled
    @event = Event.first(:conditions=>{:id => params[:event_id]})
    @event.status = Event::STATUS_ACTIVE
    @event.save
    #render :view
    
    send_mail_all_friend(@event,UserMailer::NOTIFY_CANCEL_SETTLED_DATE)
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_cancel_settle(@event)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"cancel settle" + @event.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/share_after_settled?event_id="+@event.id.to_s+"&share_unique_key="+ticket.unique_key+"&is_cancel=yes"
          redirect_url = generate_permission_url(scope,return_url)
          render :json=>{:ok=>true,:event_id=>@event.id,:redirect_url=>redirect_url}
          return
        end
    end
    
    render :json=>{:ok=>true,:event_id=>@event.id}
  end
  
  def auto_notify_to_settle
    sql = "status = '" + Event::STATUS_ACTIVE + "' and to_days(settled_date) - to_days(now()) = 3"
    @events = Event.all(:conditions=>[sql])
    @events.each do |event|
      creator = get_facebook_info(friend.facebook_id)
      UserMailer.deliver_notify_creator_to_settle(event,creator)
    end
    
  end
  
  def share_after_add
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      if params[:is_share] == "yes"
          result = inner_share(params[:event_id],params[:is_edit] == "yes")
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
     
    redirect_to "/event/view?event_id="+ params[:event_id]  
   
 end
 
 def share_after_delete
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      
      result = inner_share_delete(params[:event_id])
      
      
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to "/event/view?event_id="+ params[:event_id]  
   
 end
 
 def share_after_settled
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
    
      result = inner_share_settled(params[:event_id],params[:is_cancel] == "yes")
      
      
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to "/event/view?event_id="+ params[:event_id]  
   
  end
   
   def share_after_response
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      
      result = inner_share_response(params[:event_id],params[:event_friend_id])
     
      
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to "/event/view?event_id="+ params[:event_id]  
   
 end
 
  private
  def inner_share(event_id,is_edit)
    
    event = Event.first(:conditions=>{:id=>event_id})
    return {:ok=>false,:error_message=> "Event "+event_id+" does not exist"} if !event
    
    if !is_edit
      return $facebook.publish_invite(event) if event and event.facebook_id == $facebook.facebook_id
    else
      return $facebook.publish_edit(event) if event and event.facebook_id == $facebook.facebook_id
    end
  end
  def inner_share_delete(event_id)
    event = Event.first(:conditions=>{:id=>event_id})
    return {:ok=>false,:error_message=> "Event "+event_id+" does not exist"} if !event
 
    return $facebook.publish_delete(event) if event and event.facebook_id == $facebook.facebook_id
  end
  def inner_share_settled(event_id,is_cancel)
    event = Event.first(:conditions=>{:id=>event_id})
    return {:ok=>false,:error_message=> "Event "+event_id+" does not exist"} if !event
    
     if !is_cancel
      return $facebook.publish_settle(event) if event and event.facebook_id == $facebook.facebook_id
    else
      return $facebook.publish_cancel_settle(event) if event and event.facebook_id == $facebook.facebook_id
    end
  end
  def inner_share_response(event_id,event_friend_id)
    event = Event.first(:conditions=>{:id=>event_id})
    event_friend_response = EventFriend.first(:conditions=>{:id=>event_friend_id})
    return {:ok=>false,:error_message=> "Event "+event_id+" does not exist"} if !event
    return {:ok=>false,:error_message=> "Event friend"+event_friend_id+" does not exist"} if !event_friend_response
    
    return $facebook.publish_response(event,event_friend_response) if event and event_friend_response
    
  end
end
