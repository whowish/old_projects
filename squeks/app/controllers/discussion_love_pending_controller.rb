class DiscussionLovePendingController < ApplicationController
  include DiscussionHelper
  
  def index
    
    pending = DiscussionLovePending.first(:conditions=>{:unique_key=>params[:unique_key]})
    data = ActiveSupport::JSON.decode(pending.data)
    
    if $facebook.is_guest
      redirect_to "/discussion/view/#{data["discussion_id"]}"
      return
    end
    
    
    pending.status = DiscussionLovePending::STATUS_DONE
    pending.save
    
    
   
    $is_anonymous = true
    
    ok,figure,error_message = false,nil,""
    ok,figure,error_message = inner_love(data["discussion_id"],data["type"])
    
    redirect_to "/discussion/view/#{data["discussion_id"]}"
  end
end
