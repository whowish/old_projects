class FacebookCache
 
  def publish_feeling(figure,figure_love)
    
    if figure_love and (figure_love.love_type == FigureLove::TYPE_LOVE or figure_love.love_type == FigureLove::TYPE_HATE)
      word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"feeling_love"})
    else
      word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"feeling"})
    end
    
    if !figure_love
      figure_love = FigureLove.new
      figure_love.love_type = FigureLove::TYPE_DONT_CARE
    end

    data = {}
    data['picture'] = figure.get_thumbnail_image_url(true,true)
    data['link'] = "http://"+DOMAIN_NAME+figure.get_url+"?share_log=facebook&share_log_referer_id=#{$facebook.facebook_id}"
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    if figure_love and (figure_love.love_type == FigureLove::TYPE_LOVE or figure_love.love_type == FigureLove::TYPE_HATE)
      data['message'] = word.word_for(:message,:love_type=>figure_love.love_type.downcase,:title=>figure.title)
    else
      data['message'] = word.word_for(:message,:love_type=>figure_love.love_type.downcase,:title=>figure.title)
    end
    data['name'] = word.word_for(:name,:love_type=>figure_love.love_type.downcase,:title=>figure.title)
    data['caption'] = word.word_for(:caption,:love_type=>figure_love.love_type.downcase,:title=>figure.title)
    data['description'] = word.word_for(:description,:love_type=>figure_love.love_type.downcase,:title=>figure.title)
    
    actions = [{"name" => "View", "link"=> "http://"+DOMAIN_NAME+figure.get_url+"?share_log=facebook&share_log_referer_id=#{$facebook.facebook_id}"}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
  
    response = ActiveSupport::JSON.decode(post_data("feed",data,$facebook.facebook_id))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    return {:ok=>true}
  end
  
  def publish_comment(comment,message)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"comment"})
    
    commentor = Member.first(:conditions=>{:facebook_id=>comment.facebook_id})
    commentor_name = (comment.is_anonymous) ? "" : "by #{commentor.name}"
    
    figure = Figure.first(:conditions=>{:id=>comment.figure_id})

    data = {}
    data['picture'] = figure.get_thumbnail_image_url(true,true)
    data['link'] = "http://"+DOMAIN_NAME+"/comment/view/#{comment.id}?share_log=facebook_comment&share_log_referer_id=#{$facebook.facebook_id}"
    data['message'] = "#{message}"
  
    data['name'] = word.word_for(:name,:title=>figure.title)
    data['caption'] = word.word_for(:caption,:title=>figure.title)
    data['description'] = word.word_for(:description,:title=>figure.title,:comment=>comment.comment,:commentor=>commentor_name)
    
    actions = [{"name" => "View", "link"=> "http://"+DOMAIN_NAME+"/comment/view/#{comment.id}?share_log=facebook_comment&share_log_referer_id=#{$facebook.facebook_id}"}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
  
    response = ActiveSupport::JSON.decode(post_data("feed",data,$facebook.facebook_id))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    return {:ok=>true}
  end
  
  def publish_discussion(discussion,message)
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"discussion"})
    
    discussion_figure = DiscussionFigure.first(:conditions=>{:discussion_id=>discussion.id},:order=>"rand()")
    figure = Figure.first(:conditions=>{:id=>discussion_figure.figure_id})

    data = {}
    data['picture'] = figure.get_thumbnail_image_url(true,true)
    data['link'] = "http://"+DOMAIN_NAME+"/discussion/view/#{discussion.id}?share_log=facebook&share_log_referer_id=#{$facebook.facebook_id}"
    #data['privacy'] = "{'value':'EVERYONE'}"
    
    data['message'] = "#{message}"
    data['name'] = word.word_for(:name,:title=>discussion.title)
    data['caption'] = word.word_for(:caption,:title=>discussion.title)
    data['description'] = word.word_for(:description,:title=>discussion.title)
    
    actions = [{"name" => "View", "link"=> "http://"+DOMAIN_NAME+"/discussion/view/#{discussion.id}?share_log=facebook&share_log_referer_id=#{$facebook.facebook_id}"}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
  
    response = ActiveSupport::JSON.decode(post_data("feed",data,$facebook.facebook_id))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    return {:ok=>true}
  end
  
  
  def publish_discussion_comment(comment,message)
    
    word = WhowishWordFacebook.first(:conditions=>{:publish_id=>"discussion_comment"})
    
    commentor = Member.first(:conditions=>{:facebook_id=>comment.facebook_id})
    commentor_name = (comment.is_anonymous) ? "" : "by #{commentor.name}"
    
    discussion = Discussion.first(:conditions=>{:id=>comment.discussion_id})
    discussion_figure = DiscussionFigure.first(:conditions=>{:discussion_id=>comment.discussion_id},:order=>"rand()")
    figure = Figure.first(:conditions=>{:id=>discussion_figure.figure_id})

    data = {}
    data['picture'] = figure.get_thumbnail_image_url(true,true)
    data['link'] = "http://"+DOMAIN_NAME+"/discussion/view/#{comment.discussion_id}?share_log=facebook_discussion_comment&share_log_referer_id=#{$facebook.facebook_id}"
    data['message'] = "#{message}"
  
    data['name'] = word.word_for(:name,:title=>discussion.title)
    data['caption'] = word.word_for(:caption,:title=>discussion.title)
    data['description'] = word.word_for(:description,:title=>discussion.title,:comment=>comment.comment,:commentor=>commentor_name)
    
    actions = [{"name" => "View", "link"=> "http://"+DOMAIN_NAME+"/discussion/view/#{comment.discussion_id}?share_log=facebook_discussion_comment&share_log_referer_id=#{$facebook.facebook_id}"}]
    data['actions'] = ActiveSupport::JSON.encode(actions)
  
    response = ActiveSupport::JSON.decode(post_data("feed",data,$facebook.facebook_id))
    return {:ok=>false}.merge(parse_error(response)) if response['error']
    
    return {:ok=>true}
  end

end