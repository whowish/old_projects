class FlagController < ApplicationController
  def index
    
  end
  
  def save_flag
    @flag = Flag.new()
    @flag.item_id = params[:item_id]
    @flag.reason = params[:reason]
    @flag.facebook_id = $facebook.facebook_id
    @flag.created_date = Time.now
    
    Item.update_all("flags = flags + 1",{:id=>params[:item_id]})
    
    if !@flag.save
      render :json=>{:ok=>false, :error_message=>"an error has occur."}
      return
    end
    render :json=>{:ok=>true}
  end
end
