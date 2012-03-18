class Notification < ActiveRecord::Base
  
  def self.notify(entity)
    item = Item.first(:conditions=>{:id=>entity.item_id})
    
    return if !item
    
    Notification.create(:notified_facebook_id=>item.facebook_id,
                        :facebook_id=>entity.facebook_id,
                        :item_id=>entity.item_id,
                        :created_date=>Time.now)
  end
 
end