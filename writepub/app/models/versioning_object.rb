class VersioningObject
  include Mongoid::Document
  
  field :editor_member_id, :type => String
  field :created_date, :type=>DateTime
  
  
  def self.add(entity)
    if entity.class.name == Kratoo.name
      
      versioning_object = VersioningKratoo.new
      versioning_object.editor_member_id = $member.id
      versioning_object.created_date = Time.now
      versioning_object.object_data = entity
      versioning_object.kratoo_id = entity.id 
      versioning_object.save
      
    elsif entity.class.name == Reply.name
      
      versioning_object = VersioningReply.new
      versioning_object.editor_member_id = $member.id
      versioning_object.created_date = Time.now
      versioning_object.object_data = entity
      versioning_object.kratoo_id = entity.kratoo.id
      versioning_object.reply_id = entity.id
      versioning_object.save
      
    elsif entity.class.name == ReplyOfReply.name
      
      versioning_object = VersioningReplyOfReply.new
      versioning_object.editor_member_id = $member.id
      versioning_object.created_date = Time.now
      versioning_object.object_data = entity
      versioning_object.kratoo_id = entity.reply.kratoo.id
      versioning_object.reply_id = entity.reply.id
      versioning_object.reply_of_reply_id = entity.id
      versioning_object.save
      
    end
  end
  
end