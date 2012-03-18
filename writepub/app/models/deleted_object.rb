class DeletedObject
  include Mongoid::Document
  
  field :deleted_member_id, :type => String
  field :created_date, :type=>DateTime
  
  
  def self.delete(entity,member_id)
    if entity.class.name == Kratoo.name
      
      deleted_object = DeletedKratoo.new
      deleted_object.deleted_member_id = member_id
      deleted_object.created_date = Time.now
      deleted_object.object_data = entity
      deleted_object.kratoo_id = entity.id 
      deleted_object.save
      
    elsif entity.class.name == Reply.name
      deleted_object = DeletedReply.new
      deleted_object.deleted_member_id = member_id
      deleted_object.created_date = Time.now
      deleted_object.object_data = entity
      deleted_object.reply_id = entity.id
      deleted_object.save
    elsif entity.class.name == ReplyOfReply.name
      deleted_object = DeletedReplyOfReply.new
      deleted_object.deleted_member_id = member_id
      deleted_object.created_date = Time.now
      deleted_object.object_data = entity
      deleted_object.reply_of_reply_id = entity.id
      deleted_object.save
    end
  end
  
end