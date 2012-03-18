class ReplyOfReplyRemover
  
  MAX_RANK = 50

  @queue = :normal
  
  def self.enqueue(reply_of_reply_id, member_id)
    Resque.enqueue(ReplyOfReplyRemover, reply_of_reply_id, member_id)
  end
  
  def self.perform(reply_of_reply_id, member_id)
    
    Rails.logger.info {"ReplyOfReplyRemover processes #{reply_of_reply_id}"}
    
    MongoidHelper.commit_database

    AgreeableNotification.where("entity.reply_of_reply_id"=>reply_of_reply_id).destroy_all
    ReplyOfReplyNotification.where(:reply_of_reply_id=>reply_of_reply_id).destroy_all
    MemberAction.where("entity.reply_of_reply_id"=>reply_of_reply_id).destroy_all
    
  end
  
  
end