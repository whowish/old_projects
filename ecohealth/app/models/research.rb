class Research < ActiveRecord::Base
    include ImageHelper
   
   def update_picture(picture_list)
      inner_update_picture(picture_list,ResearchImage,:research_id,"research")
   end
end