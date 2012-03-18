class Item < ActiveRecord::Base
  include ImageHelper
  
  PRIVACY_ALL = "ALL"
  PRIVACY_FRIENDS = "FRIENDS"
  PRIVACY_FRIENDS_OF_FRIENDS = "FRIENDS_OF_FRIENDS"
  
  ITEM_TYPE_WISH = "WISH"
  ITEM_TYPE_JUNK = "JUNK"
  
  STATUS_ACTIVE = "ACTIVE"
  STATUS_PENDING = "PENDING"
  STATUS_COMPLETED = "COMPLETED"
  STATUS_DELETED = "DELETED"
  STATUS_ABUSED = "ABUSED"
  STATUS_EXPIRED = "EXPIRED"
  #STATUS_MONETARY = "MONETARY"
  
  validates_presence_of :title, :message => "title must not be empty."
  validates_presence_of :facebook_id, :message => "facebook_id must not be empty."
  validates_presence_of :item_type, :message => "item type must not be empty."
  validate :check_item_type
    
  def check_item_type
    if item_type != Item::ITEM_TYPE_JUNK and item_type != Item::ITEM_TYPE_WISH
      errors.add(:item_type, "Invalid Item Type")
    end
  end
  
   def get_item_image(return_default=true)
    
    return_image = ItemImage.first(:conditions=>{:item_id => id})
    if return_image != nil
      return get_thumbnail_url(return_image.original_image_path,480,275)
    end
    
    if return_default == false
      return nil
    end
    
    return get_default_category_image()
  end
  
  def get_default_category_image(get_thumbnail=false)

    category = Category.first(:conditions=>{:id => category_id})
    
    return "/images/category/"+category.original_image_path if category != nil and get_thumbnail == false
    return "/images/category/"+category.thumbnail_image_path if category != nil and get_thumbnail == true
    return "/images/category/default.png"
  end
  
  def get_thumbnail_item_image(return_default=true)
    
    if is_money == 1
      return "/images/thumbnail/coin.png"
    end
    
    if default_image_path != nil and default_image_path != ""
      return get_thumbnail_url(default_image_path,50,50)
    end
    
    if return_default == false
      return nil
    end
    
    return get_default_category_image(true)
  end
  
   def update_picture(picture_list)
      inner_update_picture(picture_list,ItemImage,:item_id,"item")
   end
end
