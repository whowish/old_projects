class ReplyRemover
  
  MAX_RANK = 50

  @queue = :normal
  
  def self.enqueue(reply_id,member_id)
    Resque.enqueue(ReplyRemover,reply_id,member_id)
  end
  
  def self.perform(reply_id,member_id)
    
    Rails.logger.info {"ReplyRemover processes #{reply_id}"}
    
    MongoidHelper.commit_database
    
    reply_of_replies = ReplyOfReply.all(:conditions=>{:reply_id=>reply_id})
    
    ids = []
    reply_of_replies.each do |entity|
      
      DeletedObject.delete(entity,member_id)
      ids.push(entity.id)
      
    end
    
    ReplyOfReply.where(:_id.in=>ids).destroy_all
    
    AgreeableNotification.where("entity.reply_id"=>reply_id).destroy_all
    ReplyNotification.where(:reply_id=>reply_id).destroy_all
    MemberAction.where("entity.reply_id"=>reply_id).destroy_all
   
    
  end
  
  
end