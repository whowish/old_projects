class FacebookCache
  include ThumbnailismHelper
  
  def after_initialize

  end



  def get_friends_with_friend_records(facebook_id,force_update=false,get_remote=true)
    return [] if !facebook_id
    return [] if facebook_id == "0"
    
    friend = FacebookFriendCache.first(:conditions=>{:facebook_id=>facebook_id})
    
    if get_remote and (!friend or force_update)
      
      #get data
      friend = FacebookFriendCache.new(:facebook_id=>facebook_id,:updated_date=>Time.now) if !friend
      result_data = get_data("friends",facebook_id)

      begin 
        data = ActiveSupport::JSON.decode(result_data)["data"]
        friend.friends = data.map{ |i| i["id"]}.join(',')
#        friend.friends_of_friends  = compute_friends_of_friends(friend.friends.split(',')).join(',')
      rescue Exception=>e
        print "\n\n\n\n" + e + "\n\n\n\n"
      end
    
      friend.updated_date = Time.now
      friend.save 
      
      begin 
        data = ActiveSupport::JSON.decode(result_data)["data"]
        
        new_friends = []
        data.each do |unit|
          f = FacebookFriendRecord.new(:facebook_id=>facebook_id,
                                        :friend_id=>unit['id'],
                                        :name=>unit['name'])     
          new_friends.push(f)
          
        end
        
        FacebookFriendRecord.delete_all(["facebook_id = ?",facebook_id])
      
        if new_friends.length > 0
          all_values = "("+new_friends.map{|o| o.attributes.values.map{ |v| FacebookFriendRecord.sanitize(v) }.join(",")}.join("),(")+")"
          #print "INSERT INTO "+EventAvailableDate.quoted_table_name+" (`"+new_dates[0].attributes.keys.join("`,`")+"`) VALUES "+all_values+"\n\n"
          ActiveRecord::Base.connection.execute("INSERT INTO "+FacebookFriendRecord.quoted_table_name+" (`"+new_friends[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
        end
      rescue Exception=>e
        print "\n\n\n\n" + e + "\n\n\n\n"
      end
    end
    
    return [] if !friend
    
    if !force_update and (Time.now - friend.updated_date) > 60*60*24
      #schedule update job
      Delayed::Job.enqueue AsyncFacebookFriendCache.new(facebook_id,$oauth_token)
    end

    return (friend.friends.split(',') rescue [])
  end
  
  alias_method :old_get_friends, :get_friends
  alias_method :get_friends, :get_friends_with_friend_records

  def home_url
    return '/profile?user_id='+facebook_id
  end
  
  def publish_invite(event,friend_ids=nil)

    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"invite"})

    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookThumbnail.jpg"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"

    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "Respond", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil
    
    
    
    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end

  def publish_edit(event)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"edit"})
    
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookThumbnail.jpg"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    
    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "Respond", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil

    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end
  
  def publish_response(event,event_friend_response)
    
    word_id = "response-accept"
    word_id = "response-reject" if event_friend_response.status == EventFriend::STATUS_REJECTED
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>word_id})
    
    responder = get_facebook_info(event_friend_response.facebook_id)
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookConfirm.png"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title,:name=>responder.name)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "Respond", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
  
    response = ActiveSupport::JSON.decode(post_data("feed",data,event.facebook_id))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    return {:ok=>true}
  end
  
  def publish_settle(event,friend_ids=nil)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"settle"})
    
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookConfirm.png"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    date = event.settled_date.strftime("%d %B %Y") if event.mode == Event::MODE_DAY
    date = event.settled_date.strftime("%d %B %Y %H:%M") if event.mode == Event::MODE_TIME
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:date=>date)
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "View", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil

    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end
  
  def publish_cancel_settle(event,friend_ids=nil)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"cancel"})
    
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookCancel.png"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "Respond", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil
    
    
    
    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end
  
  def publish_delete(event)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"delete"})
    
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookCancel.png"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = word.word_for(:message,:title=>event.title)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil

    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end
  
  def publish_comment(event,comment,friend_ids=nil)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"comment"})
    
    commentor = get_facebook_info(comment.facebook_id)
    data = {}
    data['picture'] = "http://twomeetfour.heroku.com/images/facebookComment.png"
    data['link'] = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +event.id.to_s
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = word.word_for(:message,:comment=>comment.comment)
    data['name'] = word.word_for(:name,:title=>event.title)
    data['caption'] = word.word_for(:caption,:location=>((event.location == "")?"Undecided" : event.location))
    data['description'] = word.word_for(:description)
    
    actions = [{"name" => "View", "link"=> "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/event/view?event_id=" +comment.event_id.to_s}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
    
    friend_ids = EventFriend.all(:conditions=>{:event_id=>event.id}).map{|d| d.facebook_id} if friend_ids == nil
    friend_ids.push(event.facebook_id)
    
    return {:ok=>true} if friend_ids.length == 0

    response = ActiveSupport::JSON.decode(post_data("feed",data,friend_ids[0]))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    friend_ids[1..-1].each { |friend_id|
    
      next if friend_id == $facebook.facebook_id
      
      Delayed::Job.enqueue AsyncFacebookMethod.new("feed",friend_id,data,$oauth_token)
    }
    
    return {:ok=>true}
  end
  
end