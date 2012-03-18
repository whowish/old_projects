class Feed < ActiveRecord::Base
  
  ACTION_LOVE_FIGURE = "LOVE_FIGURE"
  ACTION_CREATE_FIGURE = "CREATE_FIGURE"
  ACTION_CREATE_FIGURE_IMAGE = "CREATE_FIGURE_IMAGE"
  ACTION_COMMENT = "COMMENT"
  ACTION_AGREE_COMMENT = "AGREE_COMMENT"
  ACTION_LIKE_IMAGE = "LIKE_IMAGE"
  ACTION_BID = "BID"
  ACTION_WIN_BID = "WIN_BID"
  ACTION_CREATE_DISCUSSION = "DISCUSSION"
  ACTION_LOVE_DISCUSSION = "LOVE_DISCUSSION"
  
  class << self
    
    def create_feed(entity,additional_data={})
      logger.debug {"entity=#{entity}"}
      
      case true
        when entity.instance_of?(DiscussionLove) then create_discussion_love(entity,additional_data)
        when entity.instance_of?(Discussion) then create_discussion(entity,additional_data)
        when entity.instance_of?(FigureLove) then create_figure_love(entity,additional_data)
        when entity.instance_of?(Figure) then create_figure(entity,additional_data)
        when entity.instance_of?(FigureImage) then create_figure_image(entity,additional_data)
        when entity.instance_of?(FigureImageLike) then create_figure_image_like(entity,additional_data)
        when entity.instance_of?(Comment) then create_comment(entity,additional_data)
        when entity.instance_of?(CommentAgree) then create_agree_comment(entity,additional_data)
        when entity.instance_of?(BidRequest) then create_bid(entity,additional_data)
        else raise 'Feed does not support.'
      end
      
      Delayed::Job.enqueue FeedNotificationCleaner.new if rand(1000) == 1
    end
    
#    def get_html(entity)
#      return case entity.action
#        when ACTION_LOVE_FIGURE then get_html_figure_love(entity)
#        when ACTION_CREATE_FIGURE then get_html_figure(entity)
#        when ACTION_CREATE_FIGURE_IMAGE then get_html_figure_image(entity)
#        when ACTION_AGREE_COMMENT then get_html_figure_image_like(entity)
#        when ACTION_COMMENT then create_comment(entity)
#        when ACTION_AGREE_COMMENT then get_html_agree_comment(entity)
#      end
#    end
#    
#    private
#    def get_facebook_id(facebook_id)
#      @facebook_data ||= {}
#      return @facebook_data[facebook_id] if @facebook_data[facebook_id]
#      
#      
#    end
#    
#    def get_html_figure_love(entity)
#      
#    end
    
    private
    def create_bid(entity,additional_data)
      
      if entity.status == BidRequest::STATUS_SUCCESSFUL
        create_make_bid(entity,additional_data)
      elsif entity.status == BidRequest::STATUS_SETTLED
        create_win_bid(entity,additional_data)
      end
    end

    private
    def create_make_bid(entity,additional_data)
      
      figure = Figure.first(:conditions=>{:id=>entity.figure_id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :figure_id=>entity.figure_id,
                  :bid_request_id=>entity.id,
                  :is_anonymous=>0,
                  :action=>ACTION_BID,
                  :data=>""
                  )
    end
    
    private
    def create_win_bid(entity,additional_data)
      
      figure = Figure.first(:conditions=>{:id=>entity.figure_id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :figure_id=>entity.figure_id,
                  :bid_request_id=>entity.id,
                  :is_anonymous=>0,
                  :action=>ACTION_WIN_BID,
                  :data=>""
                  )
    end

    private
    def create_discussion_love(entity,additional_data)
      
      discussion = Discussion.first(:conditions=>{:id=>entity.discussion_id})
      return if !discussion.active?(true)
      
      love_type = entity.love_type
      
      if love_type == DiscussionLove::TYPE_DONT_CARE
        if additional_data[:previous_love_type] == DiscussionLove::TYPE_LOVE
          love_type = DiscussionLove::TYPE_UNLOVE
        elsif additional_data[:previous_love_type] == DiscussionLove::TYPE_HATE
          love_type = DiscussionLove::TYPE_UNHATE
        else #invalid
          return
        end
        
      end
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :discussion_id=>entity.discussion_id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_LOVE_DISCUSSION,
                  :data=>love_type
                  )
    end
    
    def create_discussion(entity,additional_data)
      
      discussion = Discussion.first(:conditions=>{:id=>entity.id})
      return if !discussion.active?(true)
      
      Feed.create(:facebook_id=>entity.creator_facebook_id,
                  :discussion_id=>entity.id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_CREATE_DISCUSSION,
                  :data=>""
                  )
    end    
    
    private
    def create_figure_love(entity,additional_data)
      
      figure = Figure.first(:conditions=>{:id=>entity.figure_id})
      return if !figure.active?(true)
      
      love_type = entity.love_type
      
      if love_type == FigureLove::TYPE_DONT_CARE
        if additional_data[:previous_love_type] == FigureLove::TYPE_LOVE
          love_type = FigureLove::TYPE_UNLOVE
        elsif additional_data[:previous_love_type] == FigureLove::TYPE_HATE
          love_type = FigureLove::TYPE_UNHATE
        else #invalid
          return
        end
        
      end
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :figure_id=>entity.figure_id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_LOVE_FIGURE,
                  :data=>love_type
                  )
    end
    
    def create_figure(entity,additional_data)
      
      figure = Figure.first(:conditions=>{:id=>entity.id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.creator_facebook_id,
                  :figure_id=>entity.id,
                  :is_anonymous=>$is_anonymous,
                  :action=>ACTION_CREATE_FIGURE,
                  :data=>""
                  )
    end
    
    def create_figure_image(entity,additional_data)
  
      figure = Figure.first(:conditions=>{:id=>entity.figure_id})
      return if !figure.active?(true)
  
      Feed.create(:facebook_id=>$facebook.facebook_id,
                  :figure_image_id=>entity.id,
                  :figure_id=>entity.figure_id,
                  :is_anonymous=>$is_anonymous,
                  :action=>ACTION_CREATE_FIGURE_IMAGE,
                  :data=>""
                  )
    end
    
    def create_figure_image_like(entity,additional_data)
      
      figure_image = FigureImage.first(:conditions=>{:id=>entity.figure_image_id})
      
      return if !figure_image
      
      figure = Figure.first(:conditions=>{:id=>figure_image.figure_id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :figure_image_id=>entity.figure_image_id,
                  :figure_id=>figure_image.figure_id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_LIKE_IMAGE,
                  :data=>entity.like_type
                  )
    end
    
    def create_comment(entity,additional_data)
      
      this_figure_id = entity.figure_id
      if this_figure_id == 0
        @parent_comment = Comment.first(:conditions=>{:id=>entity.parent_id})
        
        return if !@parent_comment
        this_figure_id = @parent_comment.figure_id
      end
      
      figure = Figure.first(:conditions=>{:id=>this_figure_id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :comment_id=>entity.id,
                  :figure_id=>this_figure_id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_COMMENT,
                  :data=>""
                  )
    end
    
    def create_agree_comment(entity,additional_data)
      
      this_figure_id = 0
      @parent_comment = Comment.first(:conditions=>{:id=>entity.comment_id})
      
      return if !@parent_comment
      this_figure_id = @parent_comment.figure_id
      
      if this_figure_id == 0
        @parent_comment = Comment.first(:conditions=>{:id=>@parent_comment.parent_id})
        
        return if !@parent_comment
        this_figure_id = @parent_comment.figure_id
      end
      
      figure = Figure.first(:conditions=>{:id=>this_figure_id})
      return if !figure.active?(true)
      
      Feed.create(:facebook_id=>entity.facebook_id,
                  :comment_id=>entity.comment_id,
                  :figure_id=>this_figure_id,
                  :is_anonymous=>entity.is_anonymous,
                  :action=>ACTION_AGREE_COMMENT,
                  :data=>entity.agree_type
                  )
    end
  end
  
  before_create :update_time
  
  def update_time
    self.created_date = Time.now
  end
end