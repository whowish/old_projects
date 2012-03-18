class DiscussionPendingController < ApplicationController
 include DiscussionHelper
  
  def index
    
    pending = DiscussionPending.first(:conditions=>{:unique_key=>params[:unique_key]})
    data = ActiveSupport::JSON.decode(pending.data)
    
    if $facebook.is_guest
      redirect_to "/discussion"
      return
    end
    
    
    pending.status = DiscussionPending::STATUS_DONE
    pending.save
    
    
   
    $is_anonymous = (data["is_anonymous"]=="yes")?true:false
    
    ok,discussion,error_message = false,nil,""
    ok,discussion,error_message = inner_create(data["title"],data["description"],data["figure_list_id"])
    
    redirect_to "/discussion/view/#{discussion.id}"
  end
end
