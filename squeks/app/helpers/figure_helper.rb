module FigureHelper
  
  def inner_love(figure_id,love_type)
    @figure = Figure.first(:conditions=>{:id => figure_id})
    
    if !@figure.active?
      return false,nil,"This figure is not valid anymore because it is deleted by admin."
    end


    Lock.generate("Love",$member.facebook_id,@figure.id).synchronize {

      @figure_love = FigureLove.first(:conditions=>{:figure_id=>@figure.id,:facebook_id=>$member.facebook_id})

      if !@figure_love
        @figure_love = FigureLove.new
        @figure_love.figure_id = @figure.id
        @figure_love.facebook_id = $member.facebook_id
        @figure_love.love_type = nil
        
      end

      if @figure_love.love_type != love_type
  
        if [FigureLove::TYPE_LOVE,FigureLove::TYPE_HATE].include?(@figure_love.love_type) \
            and love_type == FigureLove::TYPE_DONT_CARE
          $facebook.add_credit(-POINT_LOVE_FIGURE) 
        end
        
        if [FigureLove::TYPE_LOVE,FigureLove::TYPE_HATE].include?(love_type) \
            and (@figure_love.love_type == FigureLove::TYPE_DONT_CARE or @figure_love.love_type == nil)
          $facebook.add_credit(POINT_LOVE_FIGURE) 
        end
        
        case @figure_love.love_type
          when FigureLove::TYPE_LOVE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `loves` = `loves` - '1' WHERE `id`='"+ @figure.id.to_s + "'")
          when FigureLove::TYPE_HATE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `hates` = `hates` - '1' WHERE `id`='"+ @figure.id.to_s + "'")
          when FigureLove::TYPE_DONT_CARE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `dont_cares` = `dont_cares` - '1' WHERE `id`='"+ @figure.id.to_s + "'")
        end

        case love_type
          when FigureLove::TYPE_LOVE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `loves` = `loves` + '1' WHERE `id`='"+ @figure.id.to_s + "'")
          when FigureLove::TYPE_HATE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `hates` = `hates` + '1' WHERE `id`='"+ @figure.id.to_s + "'")
          when FigureLove::TYPE_DONT_CARE; ActiveRecord::Base.connection.execute("UPDATE `figures` SET `dont_cares` = `dont_cares` + '1' WHERE `id`='"+ @figure.id.to_s + "'")
        end

        previous_love_type = @figure_love.love_type
        @figure_love.love_type = love_type
        @figure_love.is_anonymous = $is_anonymous
        @figure_love.created_date = Time.now
        @figure_love.save
        
        Feed.create_feed(@figure_love,{:previous_love_type=>previous_love_type})
      end
    }

    @figure = Figure.first(:conditions=>{:id => figure_id})
    
    return true,@figure,""
    

  end
  
  def update_figure_tag(tag_list)
      tag_list = tag_list.strip

      tags_text = []

      if tag_list != ""
        tags_text = tag_list.split(",").map{ |i| i.strip}.select{|x| x != ""}.map { |i| i.split(' ').join(' ')}
      end

      tags = []
      
      tags_text.each do |text|
        t = Tag.first(:conditions=>{:name=>text.capitalize})
        if !t
          t = Tag.new()
          t.name = text.capitalize
          t.parent_id = 0
          t.save
        end
        tags.push(t.id)
      end
      
      tags.uniq!

      FigureTag.delete_all(["figure_id = :figure_id",{:figure_id=>id}])
 
      new_tags = []
      tags.each do |tag|
        figureTag = FigureTag.new
        figureTag.figure_id = id
        figureTag.tag_id = tag
        new_tags.push(figureTag)
      end
      
      
      if  new_tags.length > 0
        all_values = "("+new_tags.map{|o| o.attributes.values.map{ |v| FigureTag.sanitize(v) }.join(",")}.join("),(")+")"
        ActiveRecord::Base.connection.execute("INSERT INTO "+FigureTag.quoted_table_name+" (`"+new_tags[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
      end
    
      cols = ["title_us","title_jp","title_kr","title_cn","title_th"].map{ |m| "`#{m}` = #{FigureTag.sanitize(self[m])}"}
 
      ActiveRecord::Base.connection.execute("UPDATE #{FigureTag.quoted_table_name} SET #{cols.join(",")} WHERE `figure_id`='#{self.id}'")

  end
end
