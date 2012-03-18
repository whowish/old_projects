class KratooActionEntity < MemberActionEntity

  field :kratoo_id, :type=>String
  
  def self.create_form(kratoo_id)
    
    kratoo = Kratoo.only(:title).where(:_id=>kratoo_id).entries.first
    raise MemberActionEntityNotExist, "Kratoo(#{kratoo_id}) does not exist." if !kratoo
    
    entity = KratooActionEntity.new(:kratoo_id=>kratoo.id)
    entity.content = kratoo.title
    return entity
    
  end
  
  def self.get_previous_action(action_class,member_id,kratoo_id)
    action_class.first(:conditions=>{:member_id=>member_id,"entity.kratoo_id"=>kratoo_id})
  end
  
end