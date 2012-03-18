class CommentPendingController < ApplicationController
  include CommentHelper

  def index
    
    pending = CommentPending.first(:conditions=>{:unique_key=>params[:unique_key]})
    data = ActiveSupport::JSON.decode(pending.data)
    
    if $facebook.is_guest
      redirect_to "/home/#{data["item_id"]}"
      return
    end
    
    
    pending.status = CommentPending::STATUS_DONE
    pending.save

    ok,comment_obj,error_message = inner_save_comment(data["comment"],data["item_id"])
    
    redirect_to "/item/view/#{data["item_id"]}"

  end
  
end
