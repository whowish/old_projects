class AlbumPosterController < ApplicationController
  
  def index
    
    if $facebook.is_guest
      render :login
      return
    end
    
    session[:only_digital] = false
    
    $facebook.update_friend_records
    
    friends = []
    begin
      friend_lists = $facebook.query("SELECT flid,name FROM friendlist WHERE owner=me()")
    rescue
      render :login
      return
    end
    
    render :index
  end
  
  def only_digital
    index
    session[:only_digital] = true
  end
  
  def friend
    friends = FacebookFriendRecord.all(:conditions=>["facebook_id = :facebook_id AND name LIKE :q",{:facebook_id=>$facebook.facebook_id,:q=>params[:q]+'%'}],:order=>"name ASC",:limit=>20)
    
    if friends.length < 20
      friends = friends + FacebookFriendRecord.all(:conditions=>["facebook_id = :facebook_id AND name LIKE :q AND NOT(name LIKE :q_front)",{:facebook_id=>$facebook.facebook_id,:q=>'%'+params[:q]+'%',:q_front=>params[:q]+'%'}],:order=>"name ASC",:limit=>(20-friends.length))
    end
    render :json=>{:result=>friends.map{|d|d.name}}
  end
  
  def show_album
    
    where_clause = ""
    
    if params[:me] == "true"
      where_clause = "owner=me()"
    else
      this_friend = FacebookFriendRecord.first(:conditions=>["facebook_id = ? AND (name LIKE ? OR name LIKE ?)",$facebook.facebook_id,params[:friend_name].strip,params[:friend_name]])
      where_clause = "owner='#{this_friend.friend_id}'"
    end
    
    albums = $facebook.query("SELECT cover_pid,aid,name,link,size FROM album WHERE #{where_clause}")
    
    album_cover_url = $facebook.query("SELECT src_small,pid FROM photo WHERE pid IN (SELECT cover_pid FROM album WHERE #{where_clause})")
  
    hash_cover_url = {}
    album_cover_url.each{ |d| hash_cover_url[d['pid']] = d['src_small'] }
    
    albums.each { |album| album['cover_image_url'] = hash_cover_url[album['cover_pid']]; }
    
    render :json=>{:ok=>true,:html=>render_to_string(:partial=>"album_list",:locals=>{:albums=>albums})}
  end
  
end
