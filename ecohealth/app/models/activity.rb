class Activity < ActiveRecord::Base
   include ImageHelper
   
   def update_picture(picture_list)
      inner_update_picture(picture_list,ActivityImage,:activity_id,"activity")
   end
end