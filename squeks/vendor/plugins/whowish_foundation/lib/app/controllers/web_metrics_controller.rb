class WebMetricsController < ActionController::Base
  helper :all
  layout "blank"
  
  def change_type
    
    activity = WebMetricsActivity.first(:conditions=>{:id=>params[:id]})
    activity.action_type = params[:action_type]
    activity.save
    
    others = WebMetricsActivity.all(:conditions=>["NOT(id = ?) AND controller=? AND action=?",params[:id],activity.controller,activity.action])
    
    other_ids = []
    others.each do |entity|
      other_ids.push(entity.id)
      entity.destroy
    end
    
    render :json=>{:ok=>true,:action_type=>activity.action_type,:other_ids=>other_ids}
    
  end
  
  def swipe_data
    Delayed::Job.enqueue WebMetricsSwiper.new(params[:recalculate_all]=="true")
    
    render :text=>"Swiper is queued"
  end
end
