class CommentController < ApplicationController
  include CommentHelper
  
  def index
    @item = Item.first(:conditions=>{:id => params[:item_id]})
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"comment_panel",:locals=>{:item=>@item})}
  end

  def save_comment
    
    if $facebook.is_guest
      pending = CommentPending.new
      pending.status = CommentPending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:item_id=>params[:item_id],:comment=>params[:comment].strip})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/comment_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,@comment,error_message = inner_save_comment(params[:comment],params[:item_id])
    
    if ok
      render :json => {:ok=>true,:html=>(render_to_string :partial=>"comment_view",:locals=>{:comment=>@comment})}
    else
      render :json => {:ok=>false,:error_message=>error_message}
    end
  end
  
  def delete
    @comment = Comment.first(:conditions=>{:id=>params[:comment_id]})
    @comment.destroy if @comment
    render :json => {:ok=>true}
  end
end
