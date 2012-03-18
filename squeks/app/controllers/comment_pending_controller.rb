class CommentPendingController < ApplicationController
  
  def index
    
    if $facebook.is_guest
      redirect_to "/home/#{@figure.id}"
      return
    end
    
    pending = CommentPending.first(:conditions=>{:unique_key=>params[:unique_key]})
    
    pending.status = CommentPending::STATUS_DONE
    pending.save
    
    data = ActiveSupport::JSON.decode(pending.data)
    
    
    ok,comment_obj,error_message = false,nil,""
    
    $is_anonymous = true
    
    if data[:type] == "sub_comment"
      ok,comment_obj,error_message = inner_save_sub_comment(data["comment"],data["parent_id"])
      
      redirect_to "/comment/view/#{comment_obj.id}"
    else
      
      @figure = Figure.first(:conditions=>{:id => data["figure_id"]})
      ok,comment_obj,error_message = inner_save_comment(data["comment"],@figure)
      
      if ok
        redirect_to "/comment/view/#{comment_obj.id}"
      else
        redirect_to "/home/#{@figure.id}"
      end
    end
    
  end
  
end
