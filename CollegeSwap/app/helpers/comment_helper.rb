module CommentHelper
  
  def inner_save_comment(comment_data,item_id)
    @item = Item.first(:conditions=>{:id => item_id})
    
    if !@item
      return false,nil,"Item not found"
    end
    
    @comment = Comment.new
    @comment.facebook_id = $facebook.facebook_id
    @comment.item_id = @item.id
    @comment.comment = comment_data
    @comment.created_date = Time.now
    
    Notification.notify(@comment)
   
    if !@comment.save
      return false,nil,""
    end
  
    return true,@comment,""
  end

end