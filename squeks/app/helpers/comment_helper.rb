module CommentHelper
  
  def inner_save_sub_comment(comment_data,parent_id)
    @parent_comment = Comment.first(:conditions=>{:id=>parent_id})
    
    if !@parent_comment
      return false,nil,"The comment that you reply does not exist."
    end

    @comment = Comment.new
    @comment.facebook_id = $member.facebook_id
    @comment.is_anonymous = $is_anonymous
    @comment.figure_id = @parent_comment.figure_id
    @comment.comment = comment_data.strip
    @comment.created_date = Time.now
    @comment.agrees = 0
    @comment.disagrees = 0
    @comment.parent_id = parent_id
    @comment.status = Comment::STATUS_ACTIVE

    if !@comment.save
      return false,nil,"Comment Error"
    end
    
    Feed.create_feed(@comment)
    Notification.notify(@comment)
    $facebook.add_credit(POINT_ADD_COMMENT)
    
    return true,@comment,""
  end
  
  def inner_save_comment(comment_data,figure)
    #check duplicate
    count_duplicate = Comment.count(:conditions=>{:facebook_id=>$member.facebook_id, :figure_id=>figure.id, :comment=>comment_data.strip})
    
    if count_duplicate > 0
      return false,nil,"Your comment was previously submitted. Please reload the page to see it."
    end
    
    # merge into latest comment
    latest_comment = Comment.first(:conditions=>{:facebook_id=>$member.facebook_id, :figure_id=>figure.id},:order=>"created_date DESC")

    if latest_comment and (Time.now-latest_comment.created_date) < 60*5
      sub_comment_count = Comment.count(:conditions=>{:parent_id=>latest_comment.id})
      
      if sub_comment_count == 0
        
        latest_comment.comment = latest_comment.comment + "\r\n\r\n"+ comment_data.strip
        latest_comment.save
        
        latest_comment.comment = comment_data.strip
        
        $facebook.add_credit(POINT_ADD_COMMENT)
        Feed.create_feed(latest_comment)
        
        return true,latest_comment,""
      end
      
    end
    
    @comment = Comment.new
    @comment.facebook_id = $member.facebook_id
    @comment.is_anonymous = $is_anonymous
    @comment.figure_id = figure.id
    @comment.comment = comment_data.strip
    @comment.created_date = Time.now
    @comment.agrees = 0
    @comment.disagrees = 0
    @comment.total_agree = 0
    @comment.parent_id = 0
    @comment.status = Comment::STATUS_ACTIVE
   
    if !@comment.save
      return false,nil,"Comment error"
    end
    
    $facebook.add_credit(POINT_ADD_COMMENT)
    Feed.create_feed(@comment)
    
    return true,@comment,""
  end
  
end
