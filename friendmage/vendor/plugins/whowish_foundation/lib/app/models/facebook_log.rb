class FacebookLog < ActiveRecord::Base
  before_create :set_time
  
  def set_time
    self.created_date = Time.now
  end
end