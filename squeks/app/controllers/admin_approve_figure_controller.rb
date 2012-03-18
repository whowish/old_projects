class AdminApproveFigureController < ApplicationController
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  layout :select_layout

  def select_layout
    if request.xhr?
      "blank"
    else
      "valhalla"
    end
  end
  before_filter :check_admin
  
  def index
    
  end
  
  def approve
    figure_list = params[:figure_list]
    figures_id = figure_list.split(",")
    figures_id = [] if figure_list == ""
    
    figures_id.each do |f_id|
      figure = Figure.first(:conditions=>{:id => f_id})
      next if !figure
      figure.status = Figure::STATUS_ACTIVE
      figure.save
      Feed.create_feed(figure)
    end
    
    render :json=>{:ok=>true}
      
  end
  def disapprove
    figure_list = params[:figure_list]
    figures_id = figure_list.split(",")
    figures_id = [] if figure_list == ""
    
    figures_id.each do |f_id|
      figure = Figure.first(:conditions=>{:id => f_id})
      next if !figure
      figure.status = Figure::STATUS_DELETED
      figure.reason = params[:reason] if params[:reason]
      figure.save
      
      creator = Member.first(:conditions=>{:facebook_id=>figure.creator_facebook_id})
      creator.add_credit(-POINT_ADD_FIGURE) if creator
    end
    
    render :json=>{:ok=>true}
  end
end
