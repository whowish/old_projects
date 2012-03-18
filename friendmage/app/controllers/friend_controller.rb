class FriendController < ApplicationController
  def search
    friends = []
    
    if params[:q].strip == ""
      friends = FacebookFriendRecord.all(:conditions=>{:facebook_id=>$facebook.facebook_id},:order=>"name ASC",:limit=>100)
    else
      friends = FacebookFriendRecord.all(:conditions=>["facebook_id = :facebook_id AND name LIKE :q",{:facebook_id=>$facebook.facebook_id,:q=>'%'+params[:q]+'%'}],:order=>"rand()",:limit=>100)
    end
    
    render :json=>friends.map{|d|{:id=>d.friend_id,:name=>d.name}}
  end
  
  def view
    friends = []
    
    sql = []
    params[:q].split(',').each { |letter|
      sql.push("name LIKE '#{letter}%%'");
    }

    friends = FacebookFriendRecord.all(:conditions=>["facebook_id = :facebook_id AND (#{sql.join(' OR ')})",{:facebook_id=>$facebook.facebook_id}],:order=>"name ASC")
    
    render :json=>friends.map{|d|{:id=>d.friend_id,:name=>d.name}}
  end  

end
