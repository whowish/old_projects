class KratooAgreeableEntity < AgreeableEntity
  
  
  field :kratoo_id, :type=>String
  
  def self.create_from(kratoo)
    self.new(:kratoo_id=>kratoo.id, :content=>kratoo.title)
  end
  
  def self.get_entity(kratoo_id)
    Kratoo.first(:conditions=>{:_id => kratoo_id})
  end

  def self.get_redundant_notification(kratoo_id, notified_member_id, notification_class)
    
    notification_class.first(:conditions=>{"entity.kratoo_id" => kratoo_id,
                                           :notified_member_id => notified_member_id,
                                           :is_read => false
                                           })
                                           
  end
  
  
end