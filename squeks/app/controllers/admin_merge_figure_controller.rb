class AdminMergeFigureController < ApplicationController
  
  layout "valhalla"
  
  before_filter :check_admin
  
  def merge
    
    main_figure = Figure.first(:conditions=>{:id => params[:main_figure_id]})
    if !main_figure
      render :json=>{:ok=>false}
      return
    end
    
    merge_list = params[:merge_figure_list]
    merge_figures_id = merge_list.split(",")
    merge_figures_id = [] if merge_list == ""
    
    merge_figures_id.each do |f_id|
      next if f_id.to_i == params[:main_figure_id].to_i
      figure = Figure.first(:conditions=>{:id => f_id})
      next if !figure
      
      figure.status = Figure::STATUS_BEING_MERGED
      figure.save
    end
    
    Delayed::Job.enqueue FigureMerger.new(params[:main_figure_id],params[:merge_figure_list])
    
    render :json=>{:ok=>true}
  end
  
  
  def split
    
#    split_list = params[:split_figure_list]
#    split_figures_id = split_list.split(",")
#    split_figures_id = [] if split_list == ""
#    split_figures_id.each do |s_id|
#      history_figure = HistoryFigure.first(:conditions=>{:id => s_id})
#      next if !history_figure
#      
#      history_figure_attributes = history_figure.attributes
#      history_figure_attributes.delete("main_figure_id")
#      
#      figure = Figure.new(history_figure_attributes)
#      figure.id = history_figure.id
#      figure.save
#      
#      history_figure_tags =  HistoryFigureTag.all(:conditions=>{:figure_id => figure.id})
#      history_figure_tags.each do |history_tag|
#        figure_tag = FigureTag.first(:conditions=>{:id => history_tag.id})
#        figure_tag.figure_id = history_tag.figure_id
#        figure_tag.save
#      end
#      
#      HistoryFigureTag.delete_all(["figure_id = :figure_id",{:figure_id=>figure.id}])
#      
#      history_figure_pics =  HistoryFigurePicture.all(:conditions=>{:figure_id => figure.id})
#      history_figure_pics.each do |history_pic|
#        figure_pic = FigureImage.first(:conditions=>{:id => history_pic.id})
#        figure_pic.figure_id = history_pic.figure_id
#        figure_pic.save
#      end
#      
#      HistoryFigurePicture.delete_all(["figure_id = :figure_id",{:figure_id=>figure.id}])
#      
#      history_figure_loves = HistoryFigureLove.all(:conditions=>{:figure_id => figure.id})
#      history_figure_loves.each do |history_figure_love|
#        figure_love = FigureLove.first(:conditions=>{:id => history_figure_love.id})
#        figure_love.figure_id = history_figure_love.figure_id
#        figure_love.save
#      end
#      
#      HistoryFigureLove.delete_all(["figure_id = :figure_id",{:figure_id=>figure.id}])
#      
#      history_comments = HistoryComment.all(:conditions=>{:figure_id => figure.id})
#      history_comments.each do |history_comment|
#        comment = Comment.first(:conditions=>{:id => history_comment.id})
#        comment.figure_id = history_comment.figure_id
#        comment.save
#      end
#      HistoryComment.delete_all(["figure_id = :figure_id",{:figure_id=>figure.id}])
#      
#      history_figure.destroy
#    end
#    render :json=>{:ok=>true}
  end
  
  def search
    where_clause = ["title_us","title_jp","title_kr","title_th","title_cn"].map { |w| "(#{w} IS NOT NULL AND #{w} LIKE :q)" }
    sql = "(#{where_clause.join(' OR ')}) AND status IN (:status)"
    
    status = Figure::STATUS_ACTIVE
    status = [Figure::STATUS_ACTIVE,Figure::STATUS_BEING_MERGED] if params[:is_main] == 'no'
    
    results = Figure.all(:conditions =>[sql,{:q=>"%#{params[:q]}%",:status=>status}])
   
    partial = "main_results"
    if(params[:is_main] == 'no')
      partial = "merged_results"
    end
    
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/admin_merge_figure/#{partial}",:locals=>{:figures=>results})}
  end
end
