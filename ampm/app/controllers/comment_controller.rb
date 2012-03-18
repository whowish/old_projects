class CommentController < ApplicationController
  include EventHelper
  
  def save_comment
    event = Event.first(:conditions=>{:id=>params[:event_id]})
    if !event
      render :json => {:ok=>false,:error_message=>"event not found"}
      return
    end
    
    @comment = Comment.new
    @comment.facebook_id = $facebook.facebook_id
    @comment.event_id = event.id
    @comment.comment = params[:comment]
    @comment.created_date = Time.now
    @comment.like = 0
   
    if !@comment.save
      render :json => {:ok=>false,:error_message=>"comment error"}
      return
    end
    
    send_mail_comment(event,@comment,UserMailer::NOTIFY_COMMENT)
    
    scope = []
    if params[:share_on_facebook] == "yes"
       
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_comment(event,@comment)
        
        if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
      
          ticket = ShareTicket.create(:permission=>scope.join(','),
                                      :created_date=>Time.now,
                                      :finished_date=>nil,
                                      :status=>ShareTicket::STATUS_PENDING,
                                      :error_message=>"",
                                      :ref=>"comment" + @comment.id.to_s) 
          
          return_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME+"/comment/share_after_add?event_id="+event.id.to_s+"&comment_id="+@comment.id.to_s+"&share_unique_key="+ticket.unique_key+"&is_share=yes"
          redirect_url = generate_permission_url(scope,return_url)
          
          render :json => {:ok=>true,:redirect_url=>redirect_url,:comment_view=> render_to_string(:partial=>"/comment/comment_view",:locals=>{:comment=>@comment})}
          return
        end
    end
    
    render :json => {:ok=>true,:comment_view=> render_to_string(:partial=>"/comment/comment_view",:locals=>{:comment=>@comment})}
    
  end
  
  def comment_like
    connection = ActiveRecord::Base.connection();
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    old_comment_like = CommentLike.first(:conditions=>{:comment_id=>@comment.id,:facebook_id=>$facebook.facebook_id})
    
    if old_comment_like
      render :json => {:ok=>true,:reply_like_button=> render_to_string(:partial=>"/comment/comment_status", :layout=>"blank",:locals=>{:entity=>@comment,:you_like=>true})}
      return
    end
    
    @comment_like = CommentLike.new
    @comment_like.comment_id = @comment.id
    @comment_like.facebook_id = $facebook.facebook_id
    @comment_like.created_date = Time.now
    @comment_like.save
    
    connection.execute("UPDATE `comments` SET `like` = `like` + '1' WHERE `id`='"+ @comment.id.to_s + "'")     
    
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    render :json => {:ok=>true,:reply_like_button=> render_to_string(:partial=>"/comment/comment_status", :layout=>"blank",:locals=>{:entity=>@comment,:you_like=>true})}
  end
  
   def comment_unlike
    connection = ActiveRecord::Base.connection();
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    @comment_like = CommentLike.first(:conditions=>{:comment_id=>@comment.id,:facebook_id=>$facebook.facebook_id})
    @comment_like.destroy if @comment_like
    
    connection.execute("UPDATE `comments` SET `like` = `like` - '1' WHERE `id`='"+ @comment.id.to_s + "'")     
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    render :json => {:ok=>true,:reply_like_button=> render_to_string(:partial=>"/comment/comment_status", :layout=>"blank",:locals=>{:entity=>@comment,:you_like=>false})}
  end
  
  def comment_delete
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    @comment.destroy if @comment
    render :json => {:ok=>true}
  end
  
  def share_after_add
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      if params[:is_share] == "yes"
          result = inner_share(params[:event_id],params[:comment_id])
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
  
  private
  def inner_share(event_id,comment_id)
    
    event = Event.first(:conditions=>{:id=>event_id})
    comment = Comment.first(:conditions=>{:id=>comment_id})
    return {:ok=>false,:error_message=> "Event "+event_id+" does not exist"} if !event
    
    
    return $facebook.publish_comment(event,comment) if event and comment
  
  end
end
