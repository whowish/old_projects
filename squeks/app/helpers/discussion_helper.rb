module DiscussionHelper
  
  def update_hour_score(score,is_love,discussion_id)
    
    now_time = Time.now.utc
    time = "#{"%04d" % now_time.year}-#{"%02d" % now_time.month}-#{"%02d" % now_time.mday}"
    hour = now_time.hour
    guid = "#{time}-#{"%02d" % hour}-#{discussion_id}"
    
    if is_love
      ActiveRecord::Base.connection.execute("INSERT INTO `discussion_hour_counts` (`guid`,`date`,`hour`,`discussion_id`,`loves`,`hates`) VALUES ('#{guid}','#{time}','#{hour}','#{discussion_id}','#{score}','0') ON DUPLICATE KEY UPDATE `loves`=`loves` + (#{score});")
    else
      ActiveRecord::Base.connection.execute("INSERT INTO `discussion_hour_counts` (`guid`,`date`,`hour`,`discussion_id`,`loves`,`hates`) VALUES ('#{guid}','#{time}','#{hour}','#{discussion_id}','0','#{score}') ON DUPLICATE KEY UPDATE `hates`=`hates` + (#{score});")
    end
  end
  
  def inner_create(title,description,figure_list_id)
   
    @discussion = Discussion.new()
    @discussion.title = title
    
    if @discussion.title == "" or @discussion.title == nil
      return false,nil,"Title cannot be blank"
    end

    @discussion.description = description
    @discussion.status = Discussion::STATUS_PENDING
    @discussion.creator_facebook_id = $member.facebook_id
    @discussion.created_date = Time.now
    @discussion.loves = 0
    @discussion.hates = 0
    @discussion.views = 0
    @discussion.dont_cares = 0
    @discussion.replies = 0
    @discussion.is_anonymous = $is_anonymous

    if !@discussion.save
      return false,nil,format_error(@discussion.errors)
    end
    
    @discussion.update_discussion_figure(figure_list_id)
    
    $facebook.add_credit(POINT_ADD_FIGURE)

    return true,@discussion,""
  end
  
  def inner_love(discussion_id,love_type)


    @discussion = Discussion.first(:conditions=>{:id => discussion_id})
    
    if !@discussion.active?
      return false,nil,"This discussion is not valid anymore because it is deleted by admin."
    end


    Lock.generate("DiscussionLove",$member.facebook_id,@discussion.id).synchronize {

      @discussion_love = DiscussionLove.first(:conditions=>{:discussion_id=>@discussion.id,:facebook_id=>$member.facebook_id})

      if !@discussion_love
        @discussion_love = DiscussionLove.new
        @discussion_love.discussion_id = @discussion.id
        @discussion_love.facebook_id = $member.facebook_id
        @discussion_love.love_type = nil
        
      end

      if @discussion_love.love_type != love_type
  
        case @discussion_love.love_type
          when DiscussionLove::TYPE_LOVE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `loves` = `loves` - '1' WHERE `id`='"+ @discussion.id.to_s + "'")
            update_hour_score(-1,true,@discussion.id)
          when DiscussionLove::TYPE_HATE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `hates` = `hates` - '1' WHERE `id`='"+ @discussion.id.to_s + "'")
            update_hour_score(-1,false,@discussion.id)
          when DiscussionLove::TYPE_DONT_CARE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `dont_cares` = `dont_cares` - '1' WHERE `id`='"+ @discussion.id.to_s + "'")
        end

        case love_type
          when DiscussionLove::TYPE_LOVE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `loves` = `loves` + '1' WHERE `id`='"+ @discussion.id.to_s + "'")
            update_hour_score(1,true,@discussion.id)
          when DiscussionLove::TYPE_HATE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `hates` = `hates` + '1' WHERE `id`='"+ @discussion.id.to_s + "'")
            update_hour_score(1,false,@discussion.id)
          when DiscussionLove::TYPE_DONT_CARE
            ActiveRecord::Base.connection.execute("UPDATE `discussions` SET `dont_cares` = `dont_cares` + '1' WHERE `id`='"+ @discussion.id.to_s + "'")
        end

        previous_love_type = @discussion_love.love_type
        @discussion_love.love_type = love_type
        @discussion_love.is_anonymous = $is_anonymous
        @discussion_love.created_date = Time.now
        @discussion_love.save
        
        Feed.create_feed(@discussion_love,{:previous_love_type=>previous_love_type})
      end
    }

    @discussion = Discussion.first(:conditions=>{:id => discussion_id})
    return true,@discussion,""
  end
  
   def update_discussion_figure(figure_list_id)
      figure_list_id = figure_list_id.strip
      love_list = []
      figure_list = []
      
      if figure_list_id != ""
        love_list = figure_list_id.split(",")
        figure_list = Figure.all(:conditions=>{:id=>love_list})
      end
      

      DiscussionFigure.delete_all(["discussion_id = :discussion_id",{:discussion_id=>self.id}])
      
      new_discussion_figure = []
      
      figure_list.each do |love_figure|
        discuss_figure = DiscussionFigure.new
        discuss_figure.discussion_id = self.id
        discuss_figure.figure_id = love_figure.id
        discuss_figure.created_date = Time.now
        new_discussion_figure.push(discuss_figure)
      end
      
      if  new_discussion_figure.length > 0
        all_values = "("+new_discussion_figure.map{|o| o.attributes.values.map{ |v| DiscussionFigure.sanitize(v) }.join(",")}.join("),(")+")"
        ActiveRecord::Base.connection.execute("INSERT INTO "+DiscussionFigure.quoted_table_name+" (`"+new_discussion_figure[0].attributes.keys.join("`,`")+"`) VALUES "+all_values)
      end

  end
end
