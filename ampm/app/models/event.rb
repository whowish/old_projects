class Event < ActiveRecord::Base
  include ImageHelper
  include EventHelper
  
  STATUS_ACTIVE = "ACTIVE"
  STATUS_COMPLETED = "COMPLETED"
  STATUS_DELETED = "DELETED"
  STATUS_SETTLED = "SETTLED"
  
  MODE_DAY = "DAY"
  MODE_TIME = "TIME"
  
  validates_presence_of :title, :message => "title must not be empty."
  validates_presence_of :facebook_id, :message => "facebook_id must not be empty."
  
   def get_event_image(return_default=true)
    
    return_image = EventImage.first(:conditions=>{:event_id => id})
    if return_image != nil
      return get_thumbnail_url(return_image.original_image_path,490,275)
    end
    
    if return_default == false
      return nil
    end
    
    return get_default_image()
  end
  
  def get_thumbnail_event_image(return_default=true)
    
    if default_image_path != nil and default_image_path != ""
      return get_thumbnail_url(default_image_path,50,50)
    end
    
    if return_default == false
      return nil
    end
    
    return get_default_category_image(true)
  end
  
  def get_default_category_image(get_thumbnail=false)

    category = Category.first(:conditions=>{:id => category_id})
    
    return "/images/category/"+category.original_image_path if category != nil and get_thumbnail == false
    return "/images/category/"+category.thumbnail_image_path if category != nil and get_thumbnail == true
    return "/images/category/default.png"
  end
  
  def get_default_image(get_thumbnail=false)
    return "/images/category/default.png"
  end
  
  def update_picture(picture_list)
      inner_update_picture(picture_list,EventImage,:event_id,"event")
  end
end
