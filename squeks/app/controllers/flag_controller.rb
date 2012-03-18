class FlagController < ApplicationController
  def index
    
  end
  
  def save_flag
    @flag = Flag.new()
    @flag.figure_id = params[:figure_id] if params[:figure_id]
    @flag.comment_id = params[:comment_id] if params[:comment_id]
    @flag.flag_type = Flag::TYPE_FIGURE if params[:figure_id]
    @flag.flag_type = Flag::TYPE_COMMENT if params[:comment_id]
    @flag.reason = params[:reason]
    @flag.facebook_id = ($facebook.facebook_id || 0)
    @flag.created_date = Time.now
    
    
    if !@flag.save
      render :json=>{:ok=>false, :error_message=>"an error has occur."}
      return
    end
    render :json=>{:ok=>true}
  end
  
  def delete
    @flag = Flag.first(:conditions=>{:id=>params[:flag_id]})
    if !@flag.destroy
      render :json=>{:ok=>false, :error_message=>"an error has occur."}
      return
    end
    render :json=>{:ok=>true}
  end
end
