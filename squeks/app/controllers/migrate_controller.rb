class MigrateController < ApplicationController
  
#  def migrate_comment
#    
#    @comments = Comment.all(:conditions=>{:parent_id=>0})
#    
#    @comments.each { |comment|
#      ActiveRecord::Base.connection.execute("UPDATE #{Comment.quoted_table_name} SET `figure_id`='#{comment.figure_id}' WHERE `parent_id`='#{comment.id}'")
#
#    }
#    
#    render :text=>"OK"
#    
#  end
#  
#  def add_title_to_tags
#    
#    
#    params[:offset] ||= 0
#    params[:offset] = params[:offset].to_i
#    
#    params[:limit] ||= 50
#    params[:limit] = params[:limit].to_i
#    
#    count = Figure.count()
#    @figures = Figure.all(:offset=>params[:offset],:limit=>params[:limit])
#    
#    @figures.each { |figure|
##      tags = FigureTag.all(:conditions=>{:figure_id=>figure.id})
#      
#      cols = ["title_us","title_jp","title_kr","title_cn","title_th"].map{ |m| "`#{m}` = #{FigureTag.sanitize(figure[m])}"}
#      
#      ActiveRecord::Base.connection.execute("UPDATE #{FigureTag.quoted_table_name} SET #{cols.join(",")} WHERE `figure_id`='#{figure.id}'")
#
#    }
#    
#    if params[:offset] < count
#      render :text=>"<a href='/migrate/add_title_to_tags?offset=#{params[:offset] + params[:limit]}'>NexT #{params[:offset] + params[:limit]}</a>"
##      redirect_to "/migrate/add_title_to_tags?offset=#{params[:offset] + params[:limit]}"
#    else
#      render :text=>"DONE"
#    end
#  end
  
end
