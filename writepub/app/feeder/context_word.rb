class ContextWord
  
  @queue = :normal
  
  POST_SCORE = 10
  REPLY_SCORE = 7
  READ_SCORE = 1
  
  class << self
    def perform(member_id,kratoo_id,read_or_reply_or_post)
      
      if !['read','reply','post'].include?(read_or_reply_or_post)
        raise 'read_or_reply must be either "read", "reply", or "post"'
      end
      
      MongoidHelper.commit_database
      
      Rails.logger.info { "ContextWord process member=#{member_id} kratoo=#{kratoo_id} op=#{read_or_reply_or_post}" }
      
      member = Member.find(member_id)
      kratoo = Kratoo.find(kratoo_id)
      
      tags = Tag.where(:_id.in=>kratoo.tag_ids)
      tags.each { |tag|
        kratoo.context_words.push(tag.name)
      }
      
      kratoo.context_words.uniq!
      
      kratoo.save
      Rails.logger.info { "Save context words #{kratoo.context_words.inspect}" }
      
      case read_or_reply_or_post
        when 'read'
          member_read(member,kratoo)
        when 'reply'
          member_reply(member,kratoo)
        when 'post'
          member_post(member,kratoo)
        end
    end
    
    def member_post(member,kratoo)
          
      return if member.is_guest
        
      kratoo.context_words.each { |word|
        new_score = $redis.zincrby(member_context_word_key(member),POST_SCORE,word)
      }
      sleep(1)
      update_rank(member)
    end
  
    def member_read(member,kratoo)
          
      return if member.is_guest
        
      kratoo.context_words.each { |word|
        new_score = $redis.zincrby(member_context_word_key(member),READ_SCORE,word)
      }
      sleep(1)
      update_rank(member)
    end
    
    def member_reply(member,kratoo)
      
      return if member.is_guest
        
      kratoo.context_words.each { |word|
        new_score = $redis.zincrby(member_context_word_key(member),REPLY_SCORE,word)
      }
      sleep(1)
      update_rank(member)
    end
    
    def update_rank(member)
      
      return if member.is_guest
      
      words = $redis.zrevrange(member_context_word_key(member),0,-1)

      words.each_with_index { |word,index|
        $redis.zadd(context_word_key(word),index,member.id)
      }
      
    end
    
    def get_score(member,word)
      return $redis.zscore(member_context_word_key(member),word)
    end
    
    def get_member(word,min,max)
      member_ids = $redis.zrange(context_word_key(word),min,max)
      
      return (member_ids || [])
    end
    
    private  
      def context_word_key(word)
        "ContextWord:#{word}"
      end
      
      def member_context_word_key(member)
        "ContextWord:Member:#{member.id}:ContextWords"
      end
      
  end
end