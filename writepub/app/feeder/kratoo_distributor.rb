class KratooDistributor
  
  MAX_RANK = 50

  @queue = :normal
  
  def self.enqueue(kratoo_id)
    Resque.enqueue(KratooDistributor,kratoo_id)
  end
  
  def self.perform(kratoo_id)
    
    Rails.logger.info {"KratooDistributor processes #{kratoo_id}"}
    
    MongoidHelper.commit_database
    
    kratoo = Kratoo.first(:conditions=>{:_id=>kratoo_id})
    Rails.logger.info { "Kratoo does not exists"} and return if !kratoo
    
    # compute context word
    tags = Tag.where(:_id.in=>kratoo.tag_ids)
    
    # query all members with those context words
    tags.each { |tag|
      member_ids = ContextWord.get_member(tag.name,0,MAX_RANK)

      member_ids.each { |member_id|
        Rails.logger.info { "Distribute to #{member_id}"}
        f = MemberFeed.new(member_id)
        f.add_kratoo_to_feed(kratoo)
      }

    }
    
  end
  
  
end