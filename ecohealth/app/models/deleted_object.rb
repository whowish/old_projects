class DeletedObject < Ohm::Model
  
  attribute :object_type
  attribute :object_id
  attribute :data
  
  def self.delete(entity)
    deleted_object = DeletedObject.new
    deleted_object.object_type = entity.class.name
    deleted_object.object_id = entity.id
    deleted_object.data = entity.to_hash.to_json
    deleted_object.save
  end
end