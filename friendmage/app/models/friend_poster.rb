class FriendPoster < ActiveRecord::Base
  STATUS_CREATING = "CREATING"
  STATUS_WAIT_FOR_PAYMENT = "WAIT_FOR_PAYMENT"
  STATUS_FINISHED = "FINISHED"
  
  before_save :calculate_height
  
  def calculate_height
    dimension = ((width - border*2 - (photo_per_row-1)*gap).to_f/photo_per_row).to_i;
    self.height = (border*2 + ((image_urls.split(',').length).to_f/photo_per_row).ceil * (dimension+gap)).to_i;
  end
end