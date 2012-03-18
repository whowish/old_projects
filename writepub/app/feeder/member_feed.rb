class MemberFeed
  
  KRATOO_IN_FEED = 50
  
  attr_accessor :id
  
  def initialize(member_id)
    @id = member_id
  end
  
  # return Kratoos that interest the member
  def get_feed
    ids = $redis.zrange(feed_list_key,0,-1)
    
    hash_ids = {}
    ids.each_index { |i| hash_ids[ids[i]] = i }

    fields_to_queried = [:title,:created_date,:kratoo_type,:reply_count,:post_owner,:agrees]
    kratoos = Kratoo.only(*fields_to_queried).where(:_id.in=>ids).entries.sort { |x, y| hash_ids[y.id] <=> hash_ids[x.id] }
    
    if kratoos.length < KRATOO_IN_FEED
      kratoos += Kratoo.desc(:score).limit(KRATOO_IN_FEED - kratoos.length).entries
    end
    
    return kratoos
  end
  
  def add_kratoo_to_feed(new_kratoo)
    
    ids = $redis.zrange(feed_list_key,0,-1)
    
    #redis_args = []
    Kratoo.where(:_id.in=>ids).each { |kratoo|
      #redis_args.push(calculate_score(kratoo))
      #redis_args.push(kratoo.id)
      Rails.logger.info { kratoo.id }
      $redis.zadd(feed_list_key,-calculate_score_relative_to_the_member(kratoo),kratoo.id)
    }
    
    Rails.logger.info { new_kratoo.id }
    
    #redis_args.push(calculate_score(new_kratoo))
    #redis_args.push(new_kratoo.id)
    $redis.zadd(feed_list_key,-calculate_score_relative_to_the_member(new_kratoo),new_kratoo.id)

    #$redis.zadd(feed_list_key,*redis_args)
    Rails.logger.info { "Remove #{KRATOO_IN_FEED}"}
    $redis.zremrangebyrank(feed_list_key,KRATOO_IN_FEED,100000)
    
  end
  
  def calculate_score_relative_to_the_member(kratoo)
    kratoo = calculate_kratoo_score(kratoo)
    
    show_count = $redis.zscore(feed_show_count_key,"#{kratoo.id}")
    show_count ||= 0
    
    # Everytime it is shown and user ignores it, the score is reduced
    # But everytime it is read the score is increase.
    score = kratoo.score - 0.3 * show_count
    
    return score
  end
  
  def calculate_kratoo_score(kratoo)

    # We consider age, views, and replies
    # - the older the kratoo is, the lower the score
    # - the more views the kratoo has, the higher the score
    # - the more replies the kratoo has, the higher the score
    
    # So here is the formula:
    # days - if it is > 7 days old, then it is penalized
    days = 7 - ((Time.now.to_i - kratoo.created_date.to_i) / 86400).to_i
    
    # views - 100 views = 1 day younger
    views = kratoo.views * 0.01
    
    # replies - 5 replies = 1 day younger
    replies = kratoo.all_reply_count * 0.2
    
    kratoo.score = days + views + replies
    kratoo.save
    return kratoo
    
  end
  
  private
    def feed_list_key
      "Feed:Member:#{self.id}:feed_ids"
    end
    
    def feed_show_count_key
      "Feed:Member:#{self.id}:feed_show_count"
    end
end