class Discussion < ActiveRecord::Base
  include DiscussionHelper
  STATUS_ACTIVE = "ACTIVE"
  STATUS_DELETED = "DELETED"
  STATUS_PENDING = "PENDING"
  
  def active?(strict=false)
    if strict
      return STATUS_ACTIVE == self.status
    else
      return [STATUS_ACTIVE,STATUS_PENDING].include?(self.status)
    end
  end
  
  def get_default_image()
    sql_params_love = {:discussion_id=>self.id} 
    sql = "discussion_id = :discussion_id"
    love_discussion_figure = DiscussionFigure.first(:conditions=>[sql,sql_params_love],:order=>"rand()")
    
    if love_discussion_figure
      love_figure = Figure.first(:conditions=>{:id=>love_discussion_figure.figure_id})
      return love_figure.get_thumbnail_image_url 
    else
      return "http://"+DOMAIN_NAME+"/images/defaultThumb.jpg"
    end
    
  end
  
  def get_love_image()
    sql_params_love = {:discussion_id=>self.id,:discussion_side=>DiscussionFigure::SIDE_LOVE} 
    sql = "discussion_id = :discussion_id and discussion_side = :discussion_side"
    love_discussion_figure = DiscussionFigure.first(:conditions=>[sql,sql_params_love],:order=>"rand()")
    
    if love_discussion_figure
      love_figure = Figure.first(:conditions=>{:id=>love_discussion_figure.figure_id})
      return "<img src='"+love_figure.get_thumbnail_image_url+"' title='"+love_figure.title+"' />"
      
    else
      return "<img src='http://"+DOMAIN_NAME+"/images/defaultThumb.jpg'/>"
    end
    
    
  end
  
  def get_hate_image()
    
    sql_params_hate = {:discussion_id=>self.id,:discussion_side=>DiscussionFigure::SIDE_HATE}
    sql = "discussion_id = :discussion_id and discussion_side = :discussion_side"
    hate_discussion_figure = DiscussionFigure.first(:conditions=>[sql,sql_params_hate],:order=>"rand()")
    
    if hate_discussion_figure
      hate_figure = Figure.first(:conditions=>{:id=>hate_discussion_figure.figure_id})
      return "<img src='"+hate_figure.get_thumbnail_image_url+"' title='"+hate_figure.title+"' />"
    else
      return "<img src='http://"+DOMAIN_NAME+"/images/defaultThumb.jpg'/>"
    end
     
  end
end