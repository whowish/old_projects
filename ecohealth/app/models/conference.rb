class Conference < ActiveRecord::Base
  include ImageHelper
   
   def update_picture(picture_list)
      inner_update_picture(picture_list,ConferenceImage,:conference_id,"conference")
   end
end