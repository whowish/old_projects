class FeedController < ApplicationController
  def index
    
  end
  
  def load_more
    params[:feed_id] ||= 0
    params[:feed_id] = params[:feed_id].to_i
    
    sql_params = {:id=>params[:feed_id]}
    sql = "id > :id"
    if params[:feed_filter] == "friend"
      sql += " AND facebook_id IN (:friend_id)"
      sql_params.merge!({:facebook_id=>$member.all_friends.push($member.facebook_id)})
    end
  
    @feeds = []
    
    if params[:feed_id] == 0
      @feeds = Feed.all(:order=>"created_date DESC",:conditions=>[sql,sql_params],:limit=>10)
    else
      @feeds = Feed.all(:order=>"created_date DESC",:conditions=>[sql,sql_params],:limit=>10).reverse
    end
    
    @facebook_data_array = []
    @figure_data_array = []
    @figure_image_data_array = []
    @comment_data_array = []
  
    @feeds.each { |entity|
      @facebook_data_array.push(entity.facebook_id) if entity.facebook_id
      @figure_data_array.push(entity.figure_id) if entity.figure_id
      @figure_image_data_array.push(entity.figure_image_id) if entity.figure_image_id
      @comment_data_array.push(entity.comment_id) if entity.comment_id
    }
  
    @facebook_data = {}
    @figure_data = {}
    @figure_image_data = {}
    @comment_data = {}
  
    Member.all(:conditions=>{:facebook_id=>@facebook_data_array}).each { |entity|
      @facebook_data[entity.facebook_id] = entity
    }
  
    Figure.all(:conditions=>{:id=>@figure_data_array}).each { |entity|
      @figure_data[entity.id] = entity
    }
  
    FigureImage.all(:conditions=>{:id=>@figure_image_data_array}).each { |entity|
      @figure_image_data[entity.id] = entity
    }
  
    Comment.all(:conditions=>{:id=>@comment_data_array}).each { |entity|
      @comment_data[entity.id] = entity
    }
    
    last_feed_id = 0
    last_feed_id = @feeds.first.id if @feeds.length > 0
    
    htmls = []
    @feeds.each{|entity| 
      begin
        htmls.push(render_to_string(:partial=>"/feed/feed_unit",:locals=>{:entity=>entity}))
      rescue
      end
    }
    
    render :json=>{:ok=>true,:feed_id=>last_feed_id,:results=>htmls}
  
  end
end
