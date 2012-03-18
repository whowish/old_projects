class SearchController < ApplicationController
  
  def find_duplicate
    limit = 5
    
    qs = params[:q].split(',,,')
    
    where_clause = ["title_us","title_jp","title_kr","title_th","title_cn"].map { |w| "(#{w} IS NOT NULL AND (#{qs.map{|q| "#{w} LIKE #{Figure.sanitize("#{q}%%")}"}.join(" OR ")}))" }
    second_where_clause = ["title_us","title_jp","title_kr","title_th","title_cn"].map { |w| "(#{w} IS NOT NULL AND (#{qs.map{|q| "#{w} LIKE #{Figure.sanitize("%%#{q}%%")}"}.join(" OR ")}))" }

#    logger.debug { where_clause.join(' OR ').inspect }
#    logger.debug { second_where_clause.join(' OR ').inspect }

    @figures = []
    
    @figures = @figures + Figure.all(:conditions=>["(#{where_clause.join(' OR ')}) AND status='#{Figure::STATUS_ACTIVE}'"],:order=>"(loves+hates) DESC",:limit=>limit)

    if @figures.length < limit
      @figures = @figures + Figure.all(:conditions=>["NOT(#{where_clause.join(' OR ')}) AND (#{second_where_clause.join(' OR ')})  AND status='#{Figure::STATUS_ACTIVE}'"],:order=>"(loves+hates) DESC",:limit=>(limit-@figures.length))
    end
    
    @figure_html = []
    @figures.each { |figure| 
      @figure_html.push((render_to_string :partial=>"figure/possible_duplicate",:locals=>{:entity=>figure}))
    }
    
    render :json=>{:ok=>true,:figures=>@figure_html}
  end
  
  def suggest
    
    limit = 5
    
    where_clause = ["title_us","title_jp","title_kr","title_th","title_cn"].map { |w| "(#{w} IS NOT NULL AND #{w} LIKE :q)" }
    second_where_clause = ["title_us","title_jp","title_kr","title_th","title_cn"].map { |w| "(#{w} IS NOT NULL AND #{w} LIKE :sq)" }
    
    @figures = []
    
    @figures = @figures + Figure.all(:conditions=>["(#{where_clause.join(' OR ')}) AND status=:status",{:q=>"#{params[:q]}%",:status=>Figure::STATUS_ACTIVE}],:order=>"(loves+hates) DESC",:limit=>limit)

    if @figures.length < limit
      @figures = @figures + Figure.all(:conditions=>["NOT(#{where_clause.join(' OR ')}) AND (#{second_where_clause.join(' OR ')}) AND status=:status",{:q=>"#{params[:q]}%",:sq=>"%#{params[:q]}%",:status=>Figure::STATUS_ACTIVE}],:order=>"(loves+hates) DESC",:limit=>(limit-@figures.length))
    end

    @figures.each { |figure|
      figure["title"] = figure.title
      figure["thumbnail_url"] = figure.get_thumbnail_image_url
    }

    render :json=>{:ok=>true,:figures=>@figures}
  end
  
end
