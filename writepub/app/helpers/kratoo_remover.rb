class KratooRemover
  
  MAX_RANK = 50

  @queue = :normal
  
  def self.enqueue(kratoo_id,member_id)
    Resque.enqueue(KratooRemover,kratoo_id,member_id)
  end
  
  def self.perform(kratoo_id,member_id)
    
    Rails.logger.info {"KratooRemover processes #{kratoo_id}"}
    
    MongoidHelper.commit_database
    
    replies = Reply.all(:conditions=>{:kratoo_id=>kratoo_id})
    
    ids = []
    replies.each do |entity|
      
      DeletedObject.delete(entity,member_id)
      ids.push(entity.id)
      
    end
    
    Reply.where(:_id.in=>ids).destroy_all
    
    AgreeableNotification.where("entity.kratoo_id"=>kratoo_id).destroy_all
    MemberAction.where("entity.kratoo_id"=>kratoo_id).destroy_all
   
    
  end
  
  
end