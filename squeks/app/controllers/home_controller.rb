class HomeController < ApplicationController

  NUM_SUGGEST = 1
  def index

    return if params[:add_title]

    figure = nil
    if params[:figure_query] and params[:figure_query].strip != ""
      
      qs = [params[:figure_query].gsub("_"," "),params[:figure_query]]
      
      qs.each { |q|
      
        clauses = ["title_us","title_th","title_jp","title_kr","title_cn"].map{ |i| "#{i} LIKE :q" }
        
        figure = Figure.first(:conditions=>["(#{clauses.join(" OR ")}) AND status in (:status)",{:q=>q,:status=>[Figure::STATUS_ACTIVE,Figure::STATUS_PENDING]}])
        figure = Figure.first(:conditions=>{:id=>q,:status=>[Figure::STATUS_ACTIVE,Figure::STATUS_PENDING]}) if !figure
        
        figure = Figure.first(:conditions=>["(#{clauses.join(" OR ")}) AND status in (:status)",{:q=>q+'%',:status=>[Figure::STATUS_ACTIVE,Figure::STATUS_PENDING]}]) if !figure
        figure = Figure.first(:conditions=>["(#{clauses.join(" OR ")}) AND status in (:status)",{:q=>'%'+q+'%',:status=>[Figure::STATUS_ACTIVE,Figure::STATUS_PENDING]}]) if !figure
        
        break if figure
      }
    end
    
    if figure
      if figure.status == Figure::STATUS_DELETED
        @figure = figure
        render "home/figure_not_found"
      else
        @figure = figure
      end
      
    else
      render "home/figure_not_found"
    end
  end

end
