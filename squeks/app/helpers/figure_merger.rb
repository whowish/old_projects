class FigureMerger 
  attr_accessor :main_figure_id,:merge_figure_list
  
  def initialize(main_figure_id,merge_figure_list)
    @main_figure_id = main_figure_id
    @merge_figure_list = merge_figure_list
  end
  
  def perform
    
    main_figure = Figure.first(:conditions=>{:id => @main_figure_id})
    if !main_figure
      render :json=>{:ok=>false}
      return
    end
    
    merge_list = @merge_figure_list
    merge_figures_id = merge_list.split(",")
    merge_figures_id = [] if merge_list == ""
    
    merge_figures_id.each do |f_id|
      
      next if f_id.to_i == @main_figure_id.to_i
      
      figure = Figure.first(:conditions=>{:id => f_id})
      
      next if !figure
      
      figure.status = Figure::STATUS_BEING_MERGED
      figure.save
      
      main_figure.views = main_figure.views + figure.views
      main_figure.save
      
#      history_figure = HistoryFigure.new(figure.attributes)
#      history_figure.id = figure.id
#      history_figure.main_figure_id = main_figure.id
#      history_figure.save
      
      latest_bid = BidRequest.first(:conditions=>{:figure_id=>f_id,:status=>BidRequest::STATUS_SUCCESSFUL})
      if latest_bid
         latest_bidder = Member.first(:conditions=>{:facebook_id=>latest_bid.facebook_id})
         if latest_bidder 
            latest_bidder.add_credit(latest_bid.value)
         end
         latest_bid.status = BidRequest::STATUS_FAILED_SETTLED
         latest_bid.save
      end
      
      ActiveRecord::Base.connection.execute("UPDATE `feeds` SET `figure_id` = '"+main_figure.id.to_s+"' WHERE `figure_id`='"+ f_id.to_s + "'")
      ActiveRecord::Base.connection.execute("UPDATE `notifications` SET `figure_id` = '"+main_figure.id.to_s+"' WHERE `figure_id`='"+ f_id.to_s + "'")
      ActiveRecord::Base.connection.execute("UPDATE `flags` SET `figure_id` = '"+main_figure.id.to_s+"' WHERE `figure_id`='"+ f_id.to_s + "'")
      

      figure_tags =  FigureTag.all(:conditions=>{:figure_id => f_id})
      figure_tags.each do |tag|
#        history_figure_tag = HistoryFigureTag.new(tag.attributes)
#        history_figure_tag.id = tag.id
#        history_figure_tag.save
        
        tag.destroy
      end
      
      figure_pics =  FigureImage.all(:conditions=>{:figure_id => f_id})
      figure_pics.each do |pic|
#        history_figure_pic = HistoryFigurePicture.new(pic.attributes)
#        history_figure_pic.id = pic.id
#        history_figure_pic.save
        
        pic.figure_id = main_figure.id
        pic.save
      end
      
      figure_loves =  FigureLove.all(:conditions=>{:figure_id => f_id})
      figure_loves.each do |figure_love|
#        history_figure_love = HistoryFigureLove.new(figure_love.attributes)
#        history_figure_love.id = figure_love.id
#        history_figure_love.save
        
        main_figure_love = FigureLove.first(:conditions=>{:figure_id => main_figure.id,:facebook_id=>figure_love.facebook_id})
        if main_figure_love 
          if main_figure_love.love_type != FigureLove::TYPE_DONT_CARE
            if figure_love.love_type != FigureLove::TYPE_DONT_CARE 
               member_love = Member.first(:conditions=>{:facebook_id=>figure_love.facebook_id})
               member_love.add_credit(-POINT_LOVE_FIGURE) 
            end
            figure_love.destroy
          else #main = don'care
            if figure_love.love_type != FigureLove::TYPE_DONT_CARE
               figure_love.figure_id = main_figure.id
               figure_love.save
               
               ActiveRecord::Base.connection.execute("UPDATE `figures` SET `dont_cares` = `dont_cares` - '1' WHERE `id`='"+ main_figure.id.to_s + "'")
               
               case figure_love.love_type
                  when FigureLove::TYPE_LOVE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `loves` = `loves` + '1' WHERE `id`='"+ main_figure.id.to_s + "'")
                  when FigureLove::TYPE_HATE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `hates` = `hates` + '1' WHERE `id`='"+ main_figure.id.to_s + "'")
               end
               main_figure_love.destroy
            else #main = don't care figure_love = don't care
              figure_love.destroy
            end
          end
        else
          figure_love.figure_id = main_figure.id
          figure_love.save
   
          case figure_love.love_type
              when FigureLove::TYPE_LOVE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `loves` = `loves` + '1' WHERE `id`='"+ main_figure.id.to_s + "'")
              when FigureLove::TYPE_HATE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `hates` = `hates` + '1' WHERE `id`='"+ main_figure.id.to_s + "'")
              when FigureLove::TYPE_DONT_CARE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `dont_cares` = `dont_cares` + '1' WHERE `id`='"+ main_figure.id.to_s + "'")
          end
        end
      end
      
      comments =  Comment.all(:conditions=>{:figure_id => f_id})
      comments.each do |comment|
#        history_comment = HistoryComment.new(comment.attributes)
#        history_comment.id = comment.id
#        history_comment.save
        
        comment.figure_id = main_figure.id
        comment.save
      end
      
      figure.status = Figure::STATUS_DELETED
      figure.save
      
    end
    
  end
end