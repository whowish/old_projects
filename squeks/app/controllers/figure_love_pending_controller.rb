class FigureLovePendingController < ApplicationController
  include FigureHelper
  
  def index
    
    pending = FigureLovePending.first(:conditions=>{:unique_key=>params[:unique_key]})
    data = ActiveSupport::JSON.decode(pending.data)
     
    if $facebook.is_guest
      redirect_to "/home/#{data["figure_id"]}"
      return
    end
    

    pending.status = FigureLovePending::STATUS_DONE
    pending.save
    
    $is_anonymous = true
    
    ok,figure,error_message = false,nil,""
    ok,figure,error_message = inner_love(data["figure_id"],data["type"])
    
    redirect_to "/home/#{data["figure_id"]}"
  end
end
